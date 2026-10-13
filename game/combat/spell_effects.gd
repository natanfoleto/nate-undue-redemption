class_name SpellEffects
## Efeitos visuais das magias (10-arte-audio), com partículas blocadas: estouro, onda e nuvem.
## Os tamanhos vêm da área da magia; a aparência, do EffectLook.


## Estouro de cubinhos e um clarão rápido, em [param where], do tamanho da área.
static func burst(parent: Node, where: Vector3, color: Color, radius: float, look: EffectLook) -> void:
	var particles := _particles(color, look.burst_amount, look)
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = look.burst_lifetime
	particles.spread = 180.0
	particles.initial_velocity_min = radius * look.burst_speed.x
	particles.initial_velocity_max = radius * look.burst_speed.y
	parent.add_child(particles)
	particles.global_position = where + Vector3.UP * look.burst_lift
	particles.emitting = true
	var light := OmniLight3D.new()
	light.light_color = color
	light.omni_range = radius * look.flash_range
	particles.add_child(light)
	var tween := particles.create_tween()
	tween.tween_property(light, ^"light_energy", 0.0, look.burst_lifetime)
	tween.tween_callback(particles.queue_free)


## Onda translúcida que corre de [param origin] até o fim da linha, na largura da área.
static func wave(parent: Node, origin: Vector3, direction: Vector3, length: float, width: float, color: Color, time: float, look: EffectLook) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color, look.wave_alpha)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, look.wave_height, width * look.wave_thickness)
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	node.global_position = origin + Vector3.UP * look.wave_lift
	node.rotation.y = atan2(-direction.x, -direction.z)
	var tween := node.create_tween()
	tween.tween_property(node, ^"global_position", node.global_position + direction * length, time)
	tween.parallel().tween_property(material, ^"albedo_color:a", 0.0, time)
	tween.tween_callback(node.queue_free)


## Nuvem de cubinhos que fica em [param node] enquanto ele existir, no raio da área.
static func cloud(node: Node3D, color: Color, radius: float, look: EffectLook) -> void:
	var particles := _particles(color, look.cloud_amount, look)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius
	particles.lifetime = look.cloud_lifetime
	particles.spread = 180.0
	particles.gravity = Vector3.UP * look.cloud_rise
	particles.initial_velocity_min = look.cloud_speed.x
	particles.initial_velocity_max = look.cloud_speed.y
	particles.position = Vector3.UP * look.cloud_lift
	particles.emitting = true
	node.add_child(particles)


static func _particles(color: Color, amount: int, look: EffectLook) -> CPUParticles3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * look.cube_pixels / BoxData.PIXELS_PER_BLOCK
	mesh.material = material
	var particles := CPUParticles3D.new()
	particles.mesh = mesh
	particles.amount = amount
	particles.gravity = Vector3.ZERO
	return particles
