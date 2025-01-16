local const           = {}

const.camera_id       = "/camera#camera"
const.DISPLAY_WIDTH   = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT  = sys.get_config_number("display.height")

-- Msg pre-hashs
const.MSG             = {
	UPDATE_DEPTH_NORMAL = hash('update_depth_normal'),
	UPDATE_PIXEL_SIZE = hash('update_pixel_size'),
	UPDATE_DAFAULT_VALUES = hash('update_dafault_values')
}

-- Default Pixelart settings for shaders
const.PIXEL           = {
	pixel_size = vmath.vector4(3),
	normal_edge_coefficient = vmath.vector4(0.03),
	depth_edge_coefficient = vmath.vector4(0.3),
}

-- Scene models
const.MODELS          = {
	'/box#model',
	'/sphere#model',
	'/ronin#model',
	'/man#model',
	'/house#model',
	'/tree#model',
	'/fox#model',
	'/dance#model'
}

-- Post Process targets
const.POST_PROCESS    = {
	PIXELATE = '/post_process#pixelate_pass',
	RENDER = '/post_process#render_pixelated_pass'
}

-- Light orthographic projection settings
-- Values are per-scene dependant and must be tweaked accordingly.
const.LIGHT_PROJ      = {
	WIDTH  = 12,
	HEIGHT = 12,
	NEAR   = -20,
	FAR    = 20
}

-- Light bias matrix
const.bias_matrix     = vmath.matrix4()
const.bias_matrix.c0  = vmath.vector4(0.5, 0.0, 0.0, 0.0)
const.bias_matrix.c1  = vmath.vector4(0.0, 0.5, 0.0, 0.0)
const.bias_matrix.c2  = vmath.vector4(0.0, 0.0, 0.5, 0.0)
const.bias_matrix.c3  = vmath.vector4(0.5, 0.5, 0.5, 1.0)

const.is_gui_updating = false

return const
