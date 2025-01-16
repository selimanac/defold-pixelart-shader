local const              = require("scripts.const")

local manager            = {}

local camera_zoom        = 0

-- Lights
local light_position     = vmath.vector3()
local light_target       = vmath.vector3()
local VECTOR_UP          = vmath.vector3(0, 1, 0)
local inv_light          = vmath.matrix4()
manager.light_projection = vmath.matrix4()
manager.light_transform  = vmath.matrix4()
manager.mtx_light        = vmath.matrix4()
manager.light            = vmath.vector4()

-- invert light
local function set_light_invert()
	inv_light       = vmath.inv(manager.light_transform)
	manager.light.x = inv_light.m03
	manager.light.y = inv_light.m13
	manager.light.z = inv_light.m23
	manager.light.w = 1
end

-- set light matrix
local function set_light_matrix()
	manager.mtx_light = const.bias_matrix * manager.light_projection * manager.light_transform
end

-- set light projection
local function set_light_projection()
	manager.light_projection = vmath.matrix4_orthographic(-const.LIGHT_PROJ.WIDTH, const.LIGHT_PROJ.WIDTH, -const.LIGHT_PROJ.HEIGHT, const.LIGHT_PROJ.HEIGHT, const.LIGHT_PROJ.NEAR, const.LIGHT_PROJ.FAR)
end

-- set light trasform
local function set_light_transform()
	manager.light_transform = vmath.matrix4_look_at(light_position, light_target, VECTOR_UP)
end

-- set pixelart resolution
local function set_resolution(pixel_size)
	local res = { w = const.DISPLAY_WIDTH / pixel_size, h = const.DISPLAY_HEIGHT / pixel_size }
	local result = vmath.vector4(res.w, res.h, 1 / res.w, 1 / res.h)

	go.set(const.POST_PROCESS.PIXELATE, 'resolution', result)
	go.set(const.POST_PROCESS.RENDER, 'resolution', result)
end


local function window_resized(self, event, data)
	if event == window.WINDOW_EVENT_RESIZED then
		-- TODO Might require scale factor : https://github.com/britzl/defold-orthographic?tab=readme-ov-file#cameraset_window_scaling_factorscaling_factor
		local new_camera_zoom = math.floor(math.max(data.width / const.DISPLAY_WIDTH, data.height / const.DISPLAY_HEIGHT) * camera_zoom)

		go.set(const.camera_id, "orthographic_zoom", new_camera_zoom)
	end
end

function manager.init()
	-- Let there be light
	light_position = go.get_position('/light_source')
	light_target = go.get_position('/light_target')

	for _, v in ipairs(const.MODELS) do
		go.set(v, 'light', vmath.vector4(light_position.x, light_position.y, light_position.z, 0))
	end

	-- Set default pixelart Values
	set_resolution(const.PIXEL.pixel_size.x)
	go.set(const.POST_PROCESS.RENDER, 'normal_edge_coefficient', const.PIXEL.normal_edge_coefficient)
	go.set(const.POST_PROCESS.RENDER, 'depth_edge_coefficient', const.PIXEL.depth_edge_coefficient)

	camera_zoom = go.get(const.camera_id, "orthographic_zoom")

	-- Setup light
	set_light_transform()
	set_light_projection()
	set_light_matrix()
	set_light_invert()

	-- Add listener for zoom
	window.set_listener(window_resized)
end

function manager.message(_, message_id, message, _)
	-- Update from GUI
	if message_id == const.MSG.UPDATE_PIXEL_SIZE then
		set_resolution(message.constant_value.x)
	else
		go.set(const.POST_PROCESS.RENDER, message.constant_name, message.constant_value)
	end
end

return manager
