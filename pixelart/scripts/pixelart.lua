local pixelart              = {}

local DISPLAY_WIDTH         = sys.get_config_number("display.width")
local DISPLAY_HEIGHT        = sys.get_config_number("display.height")
pixelart.render_shadows     = true

---Default Pixel-art shader constants
local settings              = {
	pixel_size = vmath.vector4(3),
	normal_edge_coefficient = vmath.vector4(0.035),
	depth_edge_coefficient = vmath.vector4(0.3),
}

---Post Process targets
pixelart.POST_PROCESS       = {
	PIXELATE = '/pixelart_post_process#pixelate_pass',
	RENDER = '/pixelart_post_process#render_pixelated_pass'
}

---Light orthographic projection settings. Values are per-scene dependent and must be tweaked accordingly.
local light_proj            = {
	width  = 12,
	height = 12,
	near   = -20,
	far    = 20
}

---Lights
---Light bias matrix
local BIAS_MATRIX           = vmath.matrix4()
BIAS_MATRIX.c0              = vmath.vector4(0.5, 0.0, 0.0, 0.0)
BIAS_MATRIX.c1              = vmath.vector4(0.0, 0.5, 0.0, 0.0)
BIAS_MATRIX.c2              = vmath.vector4(0.0, 0.0, 0.5, 0.0)
BIAS_MATRIX.c3              = vmath.vector4(0.5, 0.5, 0.5, 1.0)

local light_source_position = vmath.vector3()
local light_target_position = vmath.vector3()
local VECTOR_UP             = vmath.vector3(0, 1, 0)
local inv_light             = vmath.matrix4()
pixelart.light_projection   = vmath.matrix4()
pixelart.light_transform    = vmath.matrix4()
pixelart.mtx_light          = vmath.matrix4()
pixelart.light              = vmath.vector4()

---Invert light
local function set_light_invert()
	inv_light        = vmath.inv(pixelart.light_transform)
	pixelart.light.x = inv_light.m03
	pixelart.light.y = inv_light.m13
	pixelart.light.z = inv_light.m23
	pixelart.light.w = 1
end

---Set light matrix
local function set_light_matrix()
	pixelart.mtx_light = BIAS_MATRIX * pixelart.light_projection * pixelart.light_transform
end

---Set light projection
local function set_light_projection()
	pixelart.light_projection = vmath.matrix4_orthographic(-light_proj.width, light_proj.width, -light_proj.height, light_proj.height, light_proj.near, light_proj.far)
end

---Set light transform
local function set_light_transform()
	pixelart.light_transform = vmath.matrix4_look_at(light_source_position, light_target_position, VECTOR_UP)
end

---Set Pixel-art resolution for post-processing shader
---@param pixel_size number Pixel size
function pixelart.set_resolution(pixel_size)
	local res = { w = DISPLAY_WIDTH / pixel_size, h = DISPLAY_HEIGHT / pixel_size }
	local result = vmath.vector4(res.w, res.h, 1 / res.w, 1 / res.h)

	go.set(pixelart.POST_PROCESS.PIXELATE, 'resolution', result)
	go.set(pixelart.POST_PROCESS.RENDER, 'resolution', result)
end

---Pixel-art post-process initial setup
---@param pixel_settings table Table of pixel-art post-process settings
---@param render_shadows? boolean Shadow post-process. Default is true
---@param light_proj_settings? table Table of light/shadow post-process settings. Required if render_shadows is 'true'.
---@param light_source? string Light source URL. Required if render_shadows is 'true'.
---@param light_target? string Light target URL. Required if render_shadows is 'true'.
function pixelart.init(pixel_settings, render_shadows, light_proj_settings, light_source, light_target)
	assert(pixel_settings, "You must provide pixel_settings")

	if render_shadows ~= nil then
		pixelart.render_shadows = render_shadows
		if pixelart.render_shadows then
			assert(light_proj_settings, "You must provide light_proj_settings")
			assert(light_source, "You must provide light_source")
			assert(light_source, "You must provide light_target")

			-- Light source positions
			light_source_position = go.get_position(light_source)
			light_target_position = go.get_position(light_target)

			light_proj.width = light_proj_settings.width
			light_proj.height = light_proj_settings.height
			light_proj.near = light_proj_settings.near
			light_proj.far = light_proj_settings.far

			-- Setup light
			set_light_transform()
			set_light_projection()
			set_light_matrix()
			set_light_invert()
		end
	elseif render_shadows == nil then
		pixelart.render_shadows = false
	end

	-- Effect settings
	settings.pixel_size = vmath.vector4(pixel_settings.pixel_size)
	settings.normal_edge_coefficient = vmath.vector4(pixel_settings.normal_edge_coefficient)
	settings.depth_edge_coefficient = vmath.vector4(pixel_settings.depth_edge_coefficient)

	-- Set default pixel-art values
	pixelart.set_resolution(settings.pixel_size.x)
	go.set(pixelart.POST_PROCESS.RENDER, 'normal_edge_coefficient', settings.normal_edge_coefficient)
	go.set(pixelart.POST_PROCESS.RENDER, 'depth_edge_coefficient', settings.depth_edge_coefficient)
end

return pixelart
