local models = {}

local light_position = vmath.vector3()

models.msg_update_constant = hash('update_constant')
models.msg_update_pixel_constant = hash('update_pixel_constant')
models.msg_update_dafault_values = hash('update_dafault_values')

local pixel_settings = {
	pixel_size = vmath.vector4(3),
	normal_edge_coefficient = vmath.vector4(0.05),
	depth_edge_coefficient = vmath.vector4(0.15),
}

models.list = {
	'/car#model', '/box#model'
}

function models.set_light_position(model_id, light_position)
	go.set(model_id, "light", vmath.vector4(light_position.x, light_position.y, light_position.z, 0))
end

function models.get_models()
	return models.list
end

function models.get_model(id)
	return models.list[id]
end

function models.get_pixel_constants()
	return pixel_settings
end

function models.init()
	-- Let there be light
	light_position = go.get_position('/light_source')
	for _, v in ipairs(models.list) do
		go.set(v, 'light', vmath.vector4(light_position.x, light_position.y, light_position.z, 0))
	end
end

return models
