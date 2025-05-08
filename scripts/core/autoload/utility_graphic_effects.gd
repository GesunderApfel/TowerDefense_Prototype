extends Node

func flash_white(sprite: CanvasItem, duration := 0.1):
	if not sprite.material:
		var mat := ShaderMaterial.new()
		mat.shader = Shader.new()
		mat.shader.code = """
			shader_type canvas_item;
			uniform float flash = 0.0;
			void fragment() {
				COLOR = texture(TEXTURE, UV);
				COLOR.rgb = mix(COLOR.rgb, vec3(1.0), flash);
			}
		"""
		sprite.material = mat
	
	var shader_mat := sprite.material as ShaderMaterial
	shader_mat.set_shader_parameter("flash", 1.0)
	
	await get_tree().create_timer(duration).timeout
	
	if is_instance_valid(sprite):
		shader_mat.set_shader_parameter("flash", 0.0)
	pass
