local manager = require("scripts.manager")


local pixelart_render = {}

function pixelart_render.init(self, create_predicates)
	local w            = render.get_width()
	local h            = render.get_height()

	-- render target buffer parameters
	local color_params = {
		format = graphics.TEXTURE_FORMAT_RGBA,
		width = w,
		height = h,
		min_filter = graphics.TEXTURE_FILTER_NEAREST,
		mag_filter = graphics.TEXTURE_FILTER_NEAREST,
		u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE
	}

	local depth_params = {
		format     = graphics.TEXTURE_FORMAT_DEPTH,
		width      = w,
		height     = h,
		min_filter = graphics.TEXTURE_FILTER_NEAREST,
		mag_filter = graphics.TEXTURE_FILTER_NEAREST,
		u_wrap     = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap     = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		flags      = render.TEXTURE_BIT -- this will create the depth buffer as a texture
	}


	-- render target buffer parameters
	local shadow_color_params              = {
		format = graphics.TEXTURE_FORMAT_RGBA,
		width = w,
		height = h,
		min_filter = graphics.TEXTURE_FILTER_NEAREST,
		mag_filter = graphics.TEXTURE_FILTER_NEAREST,
		u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE
	}

	local shadow_depth_params              = {
		format     = graphics.TEXTURE_FORMAT_DEPTH,
		width      = w,
		height     = h,
		min_filter = graphics.TEXTURE_FILTER_NEAREST,
		mag_filter = graphics.TEXTURE_FILTER_NEAREST,
		u_wrap     = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap     = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		flags      = render.TEXTURE_BIT -- this will create the depth buffer as a texture
	}

	-- render target buffers
	self.pixelart_render_target            = render.render_target(
		'pixelart_buffer',
		{
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params,
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params,
			[graphics.BUFFER_TYPE_DEPTH_BIT] = depth_params
		}
	)

	self.pixelart_pixelate_render_target   = render.render_target(
		'pixelart_pixelate_buffer',
		{
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params
		}
	)

	self.shadow_render_target              = render.render_target("shadow_buffer", {
		[graphics.BUFFER_TYPE_COLOR0_BIT] = shadow_color_params,
		[graphics.BUFFER_TYPE_DEPTH_BIT] = shadow_depth_params
	})

	--model predicate
	self.predicates['pixelart_model']      = render.predicate({ "pixelart_model" })
	self.predicates['depth_test']          = render.predicate({ "depth_test" })
	-- post process predicates
	self.predicates['post_pixelated_pass'] = render.predicate({ "render_pixelated_pass" }) -- 1st pass
	self.predicates['pixelate_pass']       = render.predicate({ "pixelate_pass" })      -- 2nd pass
	self.predicates["shadow_debug"]        = render.predicate({ "shadow_debug" })       -- shadow pass
	self.predicates["shadow_render"]       = render.predicate({ "shadow_render" })      -- shadow render

	self.light_constant_buffer             = render.constant_buffer()
	self.light_transform                   = vmath.matrix4()
	self.light_projection                  = vmath.matrix4()
	self.bias_matrix                       = vmath.matrix4()
	self.bias_matrix.c0                    = vmath.vector4(0.5, 0.0, 0.0, 0.0)
	self.bias_matrix.c1                    = vmath.vector4(0.0, 0.5, 0.0, 0.0)
	self.bias_matrix.c2                    = vmath.vector4(0.0, 0.0, 0.5, 0.0)
	self.bias_matrix.c3                    = vmath.vector4(0.5, 0.5, 0.5, 1.0)
end

function pixelart_render.update(self, state, predicates)
	---------------------------------------------------
	-- resize render targets
	render.set_render_target_size(self.pixelart_render_target, state.window_width, state.window_height)
	render.set_render_target_size(self.pixelart_pixelate_render_target, state.window_width, state.window_height)
	render.set_render_target_size(self.shadow_render_target, state.window_width, state.window_height)

	self.light_projection                     = manager.light_projection
	self.light_transform                      = manager.light_transform
	self.light_constant_buffer.light          = manager.light
	self.light_constant_buffer.mtx_light_mvp0 = manager.mtx_light.c0
	self.light_constant_buffer.mtx_light_mvp1 = manager.mtx_light.c1
	self.light_constant_buffer.mtx_light_mvp2 = manager.mtx_light.c2
	self.light_constant_buffer.mtx_light_mvp3 = manager.mtx_light.c3


	--  shadow pass
	render.set_view(self.light_transform)
	render.set_projection(self.light_projection)
	local frustum = self.light_projection * self.light_transform
	render.set_viewport(0, 0, state.window_width, state.window_height)
	render.enable_state(graphics.FACE_TYPE_FRONT)
	render.set_render_target(self.shadow_render_target, { transient = { graphics.BUFFER_TYPE_DEPTH_BIT } })
	render.clear(state.clear_buffers)

	render.enable_material("shadow_pass")
	render.draw(predicates.pixelart_model, { frustum = frustum })
	render.disable_material()

	---------------------------------------------------
	-- depth
	render.set_view(state.cameras.camera_world.view)
	render.set_projection(state.cameras.camera_world.proj)
	render.enable_state(graphics.STATE_CULL_FACE)

	render.set_render_target(self.pixelart_render_target, { transient = { graphics.BUFFER_TYPE_DEPTH_BIT } })
	render.clear(state.clear_buffers)
	render.draw(predicates.pixelart_model, { state.cameras.camera_world.options })

	render.enable_texture('shadow_render_depth_texture', self.shadow_render_target, graphics.BUFFER_TYPE_DEPTH_BIT)
	render.draw(predicates.shadow_render, { frustum = frustum, constants = self.light_constant_buffer })
	render.disable_texture('shadow_render_depth_texture')

	render.set_depth_mask(false)
	render.disable_state(graphics.STATE_CULL_FACE)

	---------------------------------------------------
	-- set quad projection
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4())

	---------------------------------------------------
	-- render pixelart_render_target to first pass
	render.set_render_target(self.pixelart_pixelate_render_target)
	render.clear(state.clear_buffers)
	render.enable_texture('diffuse_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture('normal_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture('depth_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_DEPTH_BIT)
	render.draw(predicates.post_pixelated_pass)
	render.disable_texture('diffuse_texture')
	render.disable_texture('normal_texture')
	render.disable_texture('depth_texture')

	---------------------------------------------------
	-- render pixelart_pixelate_render_target to default render target
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
	render.enable_texture('diffuse_texture', self.pixelart_pixelate_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(predicates.pixelate_pass)
	render.disable_texture('diffuse_texture')

	--[[

	---------------------------------------------------
	--debug deep render
	local s = 3
	local w = render.get_window_width() / s
	local x = render.get_window_width() - w
	local h = render.get_window_height() / s
	local y = render.get_window_height() - h

	render.set_viewport(0, y, w, h)
	render.set_projection(vmath.matrix4())
	render.set_view(vmath.matrix4())
	render.enable_texture('depth_texture', self.shadow_render_target, graphics.BUFFER_TYPE_DEPTH_BIT)
	render.draw(predicates.depth_test)
	render.disable_texture('depth_texture')
]]
	-- Reset
	render.set_viewport(0, 0, state.window_width, state.window_height)
end

return pixelart_render
