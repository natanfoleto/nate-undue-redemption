class_name SpellEffects
## Efeitos visuais das magias e do cenário (10-arte-audio), com partículas blocadas. As magias seguem o visual próprio
## de cada uma (SpellLook): a aura em Nate ao lançar, o rastro do projétil, o impacto na área (com a luz, a marca no
## chão, o tremor da tela e a pausa curta no acerto) e as partículas da área que dura. O estouro simples serve à poeira
## do cenário (EffectLook).


## Estouro de cubinhos e um clarão rápido, em [param where], do tamanho da área (a poeira do cenário).
static func burst(parent: Node, where: Vector3, color: Color, radius: float, look: EffectLook) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * look.cube_pixels / BoxData.PIXELS_PER_BLOCK
	mesh.material = material
	var particles := CPUParticles3D.new()
	particles.mesh = mesh
	particles.amount = look.burst_amount
	particles.gravity = Vector3.ZERO
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


## A aura de Nate ao lançar a magia: as camadas em volta dele, seguindo-o.
static func cast(spell: SpellData, caster: Node3D, parent: Node, direction: Vector3) -> void:
	if spell.look == null or spell.look.cast.is_empty():
		return
	var holder := play(spell.look.cast, parent, caster.global_position, direction, Vector3.ONE)
	holder.follow = caster


## O rastro do projétil da magia enquanto ele voa; os últimos cubinhos ficam no ar depois que ele some.
static func trail(spell: SpellData, projectile: Node3D, parent: Node) -> void:
	if spell.look == null or spell.look.trail.is_empty():
		return
	var holder := play(spell.look.trail, parent, projectile.global_position, Vector3.ZERO, Vector3.ONE)
	holder.follow = projectile


## O impacto da magia na área de [param attack], saindo de [param origin] na direção [param direction]: as camadas
## (correndo a faixa, se a magia corre), a luz, a marca no chão, o tremor da tela e, se ela acertou alguém
## ([param hits]), a pausa curta. Nas áreas que duram, a luz fica com elas, e a marca fica até elas acabarem.
static func impact(spell: SpellData, attack: AttackData, parent: Node, origin: Vector3, direction: Vector3, hits: int,
		stop_scale: float) -> void:
	var look := spell.look
	if look == null:
		return
	var area := area_size(attack)
	var holder := play(look.impact, parent, origin, direction, area)
	if look.sweep_time > 0.0:
		holder.sweep(origin, origin + direction * attack.reach, look.sweep_time)
	var lasts := spell.delivery == SpellData.Delivery.LASTING or spell.delivery == SpellData.Delivery.AROUND
	if look.light_energy > 0.0 and not lasts:
		holder.set_light(look.light_color, look.light_energy, look.light_range * area.x, look.light_time, false)
	mark(look, attack, parent, origin, direction, spell.lasting if lasts else 0.0)
	if look.shake > 0.0:
		Events.screen_shake.emit(look.shake, look.shake_time)
	if hits > 0:
		HitStop.freeze(look.hit_stop, stop_scale)


## As camadas de uma área que dura (a nuvem, a lama, o redemoinho em volta de Nate), seguindo-a até ela acabar, com a
## luz acesa enquanto isso.
static func lasting(spell: SpellData, area_node: Node3D, parent: Node) -> void:
	var look := spell.look
	if look == null or look.lasting.is_empty():
		return
	var area := area_size(spell.attack)
	var holder := play(look.lasting, parent, area_node.global_position, Vector3.ZERO, area)
	holder.follow = area_node
	if look.light_energy > 0.0:
		holder.set_light(look.light_color, look.light_energy, look.light_range * area.x, look.light_time, true)


## As camadas da área que dura presas em [param target] por [param seconds] (o vento nos pés de Nate na Rajada Veloz).
static func follow_for(spell: SpellData, target: Node3D, parent: Node, seconds: float) -> void:
	if spell.look == null or spell.look.lasting.is_empty():
		return
	var holder := play(spell.look.lasting, parent, target.global_position, Vector3.ZERO, Vector3.ONE)
	holder.follow = target
	holder.end_after(seconds)


## Toca as camadas em [param where], viradas para [param direction], no tamanho da área (x: raio, y: comprimento,
## z: largura). Só com estouros, o efeito acaba sozinho; senão, quem o pediu diz quando acaba.
static func play(layers: Array[ParticleLayer], parent: Node, where: Vector3, direction: Vector3, area: Vector3) -> EffectHolder:
	var holder := EffectHolder.new()
	parent.add_child(holder)
	holder.global_position = where
	if not direction.is_zero_approx():
		holder.rotation.y = atan2(-direction.x, -direction.z)
	var all_once := true
	var longest := 0.0
	for layer in layers:
		holder.add_layer(layer.build(area), layer.delay, layer.spin)
		all_once = all_once and layer.one_shot
		longest = maxf(longest, layer.delay + layer.lifetime)
	if all_once:
		holder.end_after(longest)
	return holder


## A marca no chão com a forma da área, que fica [param hold] segundos e some aos poucos.
static func mark(look: SpellLook, attack: AttackData, parent: Node, origin: Vector3, direction: Vector3, hold: float) -> void:
	if look.mark_time <= 0.0 or look.mark_color.a <= 0.0:
		return
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = look.mark_color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if look.mark_glows:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var node := MeshInstance3D.new()
	node.mesh = AreaMesh.build(attack)
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	node.global_position = origin + Vector3.UP * WarningMarker.FLOOR_OFFSET
	if not direction.is_zero_approx():
		node.global_rotation = Vector3(0.0, atan2(-direction.x, -direction.z), 0.0)
	var tween := node.create_tween()
	tween.tween_interval(hold)
	tween.tween_property(material, ^"albedo_color:a", 0.0, look.mark_time).set_ease(Tween.EASE_IN)
	tween.tween_callback(node.queue_free)


## O tamanho da área para as formas das camadas: x, o raio; y, o comprimento; z, a largura.
static func area_size(attack: AttackData) -> Vector3:
	if attack.shape == AttackData.Shape.RECTANGLE:
		return Vector3(attack.width / 2.0, attack.reach, attack.width)
	return Vector3(attack.reach, attack.reach, attack.reach * 2.0)
