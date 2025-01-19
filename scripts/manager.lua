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
	-- Init pixel-art post-process
	-- pixelart.init(const.PIXEL_SETTINGS) --without shadows
	pixelart.init(const.PIXEL_SETTINGS, const.LIGHT_SETTINGS, const.SHADOW_SETTINGS)

	camera_zoom = go.get(const.CAMERA_ID, "orthographic_zoom")

	-- Window resize listener
	window.set_listener(window_resized)
end

return manager
