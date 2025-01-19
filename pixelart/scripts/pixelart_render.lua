local pixelart        = require("pixelart.scripts.pixelart")

local pixelart_render = {}

function pixelart_render.init(self)
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


	-- render target buffers
	self.pixelart_render_target                             = render.render_target(
		'pixelart_buffer',
		{
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params,
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params,
			[graphics.BUFFER_TYPE_DEPTH_BIT] = depth_params
		}
	)

	self.pixelart_pixelate_render_target                    = render.render_target(
		'pixelart_pixelate_buffer',
		{
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params
		}
	)

	self.shadow_render_target                               = render.render_target(
		"shadow_buffer",
		{
			[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params,
			[graphics.BUFFER_TYPE_DEPTH_BIT] = depth_params
		})

	--Pixel-art predicates
	self.pixelart_predicates                                = {}

	self.pixelart_predicates['pixelart_model']              = render.predicate({ "pixelart_model" })
	self.pixelart_predicates['pixelart_billboard_particle'] = render.predicate({ "pixelart_billboard_particle" })
	self.pixelart_predicates['pixelart_billboard_sprite']   = render.predicate({ "pixelart_billboard_sprite" })

	-- post process predicates
	self.pixelart_predicates['post_pixelated_pass']         = render.predicate({ "render_pixelated_pass" }) -- 1st pass
	self.pixelart_predicates['pixelate_pass']               = render.predicate({ "pixelate_pass" })      -- 2nd pass
	self.pixelart_predicates["shadow_render"]               = render.predicate({ "shadow_render" })      -- shadow render

	-- light
	self.light_constant_buffer                              = render.constant_buffer()
	self.light_transform                                    = vmath.matrix4()
	self.light_projection                                   = vmath.matrix4()
end

function pixelart_render.update(self, camera_frustum, view, proj)
	render.enable_state(graphics.STATE_DEPTH_TEST)

	---------------------------------------------------
	-- resize pixelart render targets
	render.set_render_target_size(self.pixelart_render_target, self.state.window_width, self.state.window_height)
	render.set_render_target_size(self.pixelart_pixelate_render_target, self.state.window_width, self.state.window_height)

	self.light_constant_buffer.light = pixelart.light
	self.light_constant_buffer.diffuse_light = pixelart.ambient_light
	self.light_constant_buffer.resolution = pixelart.settings.resolution
	self.light_constant_buffer.normal_edge_coefficient = pixelart.settings.normal_edge_coefficient
	self.light_constant_buffer.depth_edge_coefficient = pixelart.settings.depth_edge_coefficient

	if pixelart.render_shadows then
		-- resize shadow render target
		render.set_render_target_size(self.shadow_render_target, self.state.window_width, self.state.window_height)

		---------------------------------------------------
		-- lights
		self.light_projection                     = pixelart.light_projection
		self.light_transform                      = pixelart.light_transform

		--light_constant_buffer
		self.light_constant_buffer.mtx_light_mvp0 = pixelart.mtx_light.c0
		self.light_constant_buffer.mtx_light_mvp1 = pixelart.mtx_light.c1
		self.light_constant_buffer.mtx_light_mvp2 = pixelart.mtx_light.c2
		self.light_constant_buffer.mtx_light_mvp3 = pixelart.mtx_light.c3
		self.light_constant_buffer.bias           = pixelart.light_shadow_settings.depth_bias
		self.light_constant_buffer.shadow_opacity = pixelart.light_shadow_settings.shadow_opacity

		---------------------------------------------------
		--  shadow pass
		---------------------------------------------------
		render.set_view(self.light_transform)
		render.set_projection(self.light_projection)
		--	local light_frustum = self.light_projection * self.light_transform

		render.enable_state(graphics.FACE_TYPE_FRONT)
		render.set_render_target(self.shadow_render_target, { transient = { graphics.BUFFER_TYPE_DEPTH_BIT } })
		render.clear(self.state.clear_buffers)

		render.enable_material("shadow_pass")
		render.draw(self.pixelart_predicates.pixelart_model, { frustum = camera_frustum })
		render.draw(self.pixelart_predicates.shadow_render, { frustum = camera_frustum })

		render.disable_material()
	end

	---------------------------------------------------
	-- depth pass
	---------------------------------------------------

	render.set_view(view)
	render.set_projection(proj)

	render.enable_state(graphics.STATE_CULL_FACE)

	render.set_render_target(self.pixelart_render_target, { transient = { graphics.BUFFER_TYPE_DEPTH_BIT } })
	render.clear(self.state.clear_buffers)

	-- draw model to depth
	render.draw(self.pixelart_predicates.pixelart_model, { frustum = camera_frustum, constants = self.light_constant_buffer })

	-- Shadow
	if pixelart.render_shadows then
		render.enable_texture('shadow_render_depth_texture', self.shadow_render_target, graphics.BUFFER_TYPE_DEPTH_BIT)
		render.draw(self.pixelart_predicates.shadow_render, { frustum = camera_frustum, constants = self.light_constant_buffer })
		render.disable_texture('shadow_render_depth_texture')
	end

	render.disable_state(graphics.STATE_CULL_FACE)
	render.set_depth_mask(false)

	-- billboard particles and billboard sprites
	render.enable_state(graphics.STATE_BLEND)
	render.draw(self.pixelart_predicates.pixelart_billboard_sprite, { frustum = camera_frustum })
	render.draw(self.pixelart_predicates.pixelart_billboard_particle, { frustum = camera_frustum })
	render.disable_state(graphics.STATE_BLEND)

	---------------------------------------------------
	-- set quad projection
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4())

	---------------------------------------------------
	-- render pixelart_render_target to first pass
	render.set_render_target(self.pixelart_pixelate_render_target)

	render.clear(self.state.clear_buffers)

	render.enable_texture('diffuse_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture('normal_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture('depth_texture', self.pixelart_render_target, graphics.BUFFER_TYPE_DEPTH_BIT)

	render.draw(self.pixelart_predicates.post_pixelated_pass, { constants = self.light_constant_buffer })

	render.disable_texture('diffuse_texture')
	render.disable_texture('normal_texture')
	render.disable_texture('depth_texture')

	---------------------------------------------------
	-- render pixelart_pixelate_render_target to default render target
	render.set_render_target(render.RENDER_TARGET_DEFAULT)

	render.enable_texture('diffuse_texture', self.pixelart_pixelate_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(self.pixelart_predicates.pixelate_pass, { constants = self.light_constant_buffer })
	render.disable_texture('diffuse_texture')

	render.disable_state(graphics.STATE_DEPTH_TEST)
end

return pixelart_render
