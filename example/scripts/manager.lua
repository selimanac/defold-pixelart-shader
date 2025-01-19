local pixelart    = require("pixelart.scripts.pixelart")
local settings    = require("example.scripts.settings")

local manager     = {}

local camera_zoom = 0

local function window_resized(self, event, data)
	if event == window.WINDOW_EVENT_RESIZED then
		--  Might require scale factor : https://github.com/britzl/defold-orthographic?tab=readme-ov-file#cameraset_window_scaling_factorscaling_factor
		local new_camera_zoom = math.floor(math.max(data.width / settings.DISPLAY_WIDTH, data.height / settings.DISPLAY_HEIGHT) * camera_zoom)
		go.set(settings.CAMERA_ID, "orthographic_zoom", new_camera_zoom)
	end
end

function manager.init()
	-- *******************************
	-- Init pixel-art post-process
	-- *******************************

	-- pixelart.init(settings.PIXEL_SETTINGS) --without light and shadows
	-- pixelart.init(settings.PIXEL_SETTINGS, settings.LIGHT_SETTINGS) --without shadows
	pixelart.init(settings.PIXEL_SETTINGS, settings.LIGHT_SETTINGS, settings.SHADOW_SETTINGS)

	camera_zoom = go.get(settings.CAMERA_ID, "orthographic_zoom")

	-- Window resize listener
	window.set_listener(window_resized)
end

return manager
