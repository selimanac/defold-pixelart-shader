local const               = {}

const.CAMERA_ID           = "/camera#camera"
const.DISPLAY_WIDTH       = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT      = sys.get_config_number("display.height")

--  Pixelart post process settings
const.PIXEL_SETTINGS      = {
	pixel_size = 3,
	normal_edge_coefficient = 0.035,
	depth_edge_coefficient = 0.3,
}

-- Light orthographic projection settings
-- Values are per-scene dependant and must be tweaked accordingly.
const.LIGHT_PROJ_SETTINGS = {
	width  = 12,
	height = 12,
	near   = -20,
	far    = 20
}

-- Msg pre-hashs
const.MSG                 = {
	UPDATE_DEPTH_NORMAL = hash('update_depth_normal'),
	UPDATE_PIXEL_SIZE = hash('update_pixel_size'),
	UPDATE_DAFAULT_VALUES = hash('update_dafault_values')
}

-- Scene models for setting up lighting
const.MODELS              = {
	'/box#model',
	'/sphere#model',
	'/ronin#model',
	'/man#model',
	'/house#model',
	'/tree#model',
	'/fox#model',
	'/dance#model'
}

-- GUI drag-drop
const.is_gui_updating     = false

return const
