local pixelart    = require("pixelart.scripts.pixelart")
local const       = require("scripts.const")

local manager     = {}

local camera_zoom = 0

local function window_resized(self, event, data)
	if event == window.WINDOW_EVENT_RESIZED then
		-- TODO Might require scale factor : https://github.com/britzl/defold-orthographic?tab=readme-ov-file#cameraset_window_scaling_factorscaling_factor
		local new_camera_zoom = math.floor(math.max(data.width / const.DISPLAY_WIDTH, data.height / const.DISPLAY_HEIGHT) * camera_zoom)

		go.set(const.CAMERA_ID, "orthographic_zoom", new_camera_zoom)
	end
end

function manager.init()
	-- Init pixelart post-process
	-- pixelart.init(const.PIXEL_SETTINGS)
	pixelart.init(const.PIXEL_SETTINGS, true, const.LIGHT_PROJ_SETTINGS, '/light_source', '/light_target')

	-- Let there be light for models
	local light_source_position = go.get_position('/light_source')
	for _, v in ipairs(const.MODELS) do
		go.set(v, 'light', vmath.vector4(light_source_position.x, light_source_position.y, light_source_position.z, 0))
	end

	camera_zoom = go.get(const.CAMERA_ID, "orthographic_zoom")

	-- Add listener for zoom
	window.set_listener(window_resized)
end

function manager.message(_, message_id, message, _)
	-- Update from GUI
	if message_id == const.MSG.UPDATE_PIXEL_SIZE then
		pixelart.set_resolution(message.constant_value.x)
	else
		go.set(pixelart.POST_PROCESS.RENDER, message.constant_name, message.constant_value)
	end
end

return manager
