local pixelart_render = {}

function pixelart_render.init(self)
	local w                              = render.get_width()
	local h                              = render.get_height()

	-- render target buffer parameters
	local color_params                   = {
		format = render.FORMAT_RGBA,
		width = w,
		height = h,
		min_filter = render.FILTER_NEAREST,
		mag_filter = render.FILTER_NEAREST,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE
	}
	local normal_params                  = {
		format = render.FORMAT_RGBA,
		width = w,
		height = h,
		min_filter = render.FILTER_NEAREST,
		mag_filter = render.FILTER_NEAREST,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE
	}
	local depth_params                   = {
		format     = render.FORMAT_DEPTH,
		width      = w,
		height     = h,
		min_filter = render.FILTER_NEAREST,
		mag_filter = render.FILTER_NEAREST,
		u_wrap     = render.WRAP_CLAMP_TO_EDGE,
		v_wrap     = render.WRAP_CLAMP_TO_EDGE,
		flags      = render.TEXTURE_BIT -- this will create the depth buffer as a texture
	}

	-- render target buffers
	self.pixelart_render_target          = render.render_target('pixelart_buffer', { [render.BUFFER_COLOR_BIT] = color_params, [render.BUFFER_COLOR_BIT] = color_params, [render.BUFFER_DEPTH_BIT] = depth_params })
	self.pixelart_pixelate_render_target = render.render_target('pixelart_pixelate_buffer', { [render.BUFFER_COLOR_BIT] = color_params })

	--model predicate
	self.pixelart_model                  = render.predicate({ "pixelart_model" })

	-- post process predicates
	self.render_pixelated_pass_pred      = render.predicate({ "render_pixelated_pass" }) -- 1st pass
	self.pixelate_pass_pred              = render.predicate({ "pixelate_pass" })      -- 2nd pass
end

function pixelart_render.update(self, frustum, window_width, window_height)
	---------------------------------------------------
	-- resize render targets
	render.set_render_target_size(self.pixelart_render_target, window_width, window_height)
	render.set_render_target_size(self.pixelart_pixelate_render_target, window_width, window_height)

	---------------------------------------------------
	-- render pixelart_model to pixelart_render_target
	render.set_depth_mask(true)
	--render.set_blend_func(graphics.BLEND_FACTOR_SRC_ALPHA, graphics.BLEND_FACTOR_ONE_MINUS_SRC_ALPHA) -- you may want to use it if you have alpha on texture
	render.enable_state(graphics.STATE_DEPTH_TEST)
	--render.enable_state(graphics.STATE_CULL_FACE)
	render.set_render_target(self.pixelart_render_target, { transient = { render.BUFFER_DEPTH_BIT } })
	render.clear({ [render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0 })
	render.draw(self.pixelart_model, { frustum = frustum })
	render.set_depth_mask(false)
	--	render.disable_state(graphics.STATE_CULL_FACE)
	render.disable_state(render.STATE_DEPTH_TEST)

	---------------------------------------------------
	-- set quad projection
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4())

	---------------------------------------------------
	-- render pixelart_render_target to first pass
	render.set_render_target(self.pixelart_pixelate_render_target)
	render.clear({ [render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0 })
	render.enable_texture('diffuse_texture', self.pixelart_render_target, render.BUFFER_COLOR_BIT)
	render.enable_texture('normal_texture', self.pixelart_render_target, render.BUFFER_COLOR_BIT)
	render.enable_texture('depth_texture', self.pixelart_render_target, render.BUFFER_DEPTH_BIT)
	render.draw(self.render_pixelated_pass_pred)
	render.disable_texture('diffuse_texture')
	render.disable_texture('normal_texture')
	render.disable_texture('depth_texture')

	---------------------------------------------------
	-- render pixelart_pixelate_render_target to default render target
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
	render.clear({ [render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0 })
	render.enable_texture('diffuse_texture', self.pixelart_pixelate_render_target, render.BUFFER_COLOR_BIT)
	render.draw(self.pixelate_pass_pred)
	render.disable_texture('diffuse_texture')
end

return pixelart_render
