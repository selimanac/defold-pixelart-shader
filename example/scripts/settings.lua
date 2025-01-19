local settings           = {}

settings.CAMERA_ID       = "/camera#camera"
settings.DISPLAY_WIDTH   = sys.get_config_number("display.width")
settings.DISPLAY_HEIGHT  = sys.get_config_number("display.height")

--  Pixel-art post process settings
settings.PIXEL_SETTINGS  = {
	pixel_size = 2,               --Pixel size
	normal_edge_coefficient = 0.035, -- Normal edge for sharpening edges
	depth_edge_coefficient = 0.3, --Depth edge for outline
}

-- Light orthographic projection settings for shadow
-- Values are per-scene dependent and must be tweaked accordingly.
settings.SHADOW_SETTINGS = {
	projection_width  = 14,
	projection_height = 14,
	projection_near   = -80,
	projection_far    = 80,
	depth_bias        = 0.002, -- Usually, it's 0.00002 for perspective and 0.002 for orthographic projection.
	shadow_opacity    = 0.4 -- Shadow opacity
}

settings.LIGHT_SETTINGS  = {
	source = '/light_source',
	target = '/light_target',
	diffuse_light_color = vmath.vector3(0.5), -- Diffuse light color
}

return settings
