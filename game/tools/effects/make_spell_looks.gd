extends SceneTree
# Gera o visual das 10 magias (data/effects/spells/, um SpellLook por magia) e liga cada um à magia dele
# (data/spells/). Cada elemento tem as partículas dele: o fogo com chamas, brasas e fumaça; a água com espuma, gotas e
# corpo d'água; a terra com pedras, pedrinhas e poeira; o ar com riscos de vento e lufadas. As combinações misturam as
# partículas e as cores dos dois. Os números da magia (área, dano e tempos) não mudam. Rodar a partir da raiz do
# repositório:
#   godot --headless --path game -s res://tools/effects/make_spell_looks.gd

const LOOKS := "res://data/effects/spells/"
const SPELLS := "res://data/spells/"

# Cores dos elementos.
const FIRE_CORE := Color(1.0, 0.92, 0.55)
const FIRE := Color(1.0, 0.62, 0.2)
const FIRE_DARK := Color(0.85, 0.2, 0.06)
const SMOKE := Color(0.24, 0.2, 0.19)
const WATER_LIGHT := Color(0.92, 0.98, 1.0)
const WATER := Color(0.5, 0.78, 1.0)
const WATER_DEEP := Color(0.28, 0.55, 0.95)
const EARTH := Color(0.62, 0.46, 0.29)
const EARTH_DARK := Color(0.4, 0.28, 0.18)
const DUST := Color(0.74, 0.64, 0.5)
const AIR := Color(1.0, 1.0, 1.0)
const AIR_PALE := Color(0.85, 0.9, 1.0)
const STEAM := Color(1.0, 0.97, 0.95)
const LAVA_CORE := Color(1.0, 0.85, 0.35)
const LAVA := Color(1.0, 0.45, 0.12)
const ROCK := Color(0.24, 0.17, 0.14)
const ICE := Color(0.82, 0.95, 1.0)
const ICE_DEEP := Color(0.55, 0.82, 1.0)
const MUD := Color(0.42, 0.3, 0.18)
const MUD_LIGHT := Color(0.56, 0.43, 0.28)
const SAND := Color(0.92, 0.82, 0.57)
const SAND_DARK := Color(0.8, 0.68, 0.45)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LOOKS))
	_save("fireball", _fireball())
	_save("cutting_wave", _cutting_wave())
	_save("earth_collapse", _earth_collapse())
	_save("air_gust", _air_gust())
	_save("vapor", _vapor())
	_save("magma", _magma())
	_save("fire_storm", _fire_storm())
	_save("ice", _ice())
	_save("mud", _mud())
	_save("sand_shield", _sand_shield())
	quit()


func _save(spell_name: String, look: SpellLook) -> void:
	var look_path := LOOKS + spell_name + ".tres"
	print(look_path, ": ", error_string(ResourceSaver.save(look, look_path)))
	var spell_path := SPELLS + spell_name + ".tres"
	var spell := load(spell_path) as SpellData
	spell.look = load(look_path)
	print(spell_path, ": ", error_string(ResourceSaver.save(spell, spell_path)))


func _layer(values: Dictionary) -> ParticleLayer:
	var layer := ParticleLayer.new()
	for key: String in values:
		layer.set(key, values[key])
	return layer


static func _fade(color: Color, alpha := 0.0) -> Color:
	return Color(color, alpha)


# A aura de Nate ao lançar, nas cores da magia: um anel que abre nos pés e faíscas nas mãos (em blocos).
func _aura(first: Color, second: Color) -> Array[ParticleLayer]:
	return [
		_layer({"color_start": first, "color_end": _fade(first), "amount": 18, "lifetime": 0.45, "shape": ParticleLayer.Shape.RING,
			"shape_size": Vector3(0.6, 0.05, 0.8), "lift": 0.1, "direction": Vector3.UP, "spread": 10.0, "speed": Vector2(1.0, 2.0),
			"radial": 2.0, "damping": 1.0, "size_pixels": Vector2(2, 3), "glows": true}),
		_layer({"color_start": second, "color_end": _fade(second), "amount": 10, "lifetime": 0.6, "shape": ParticleLayer.Shape.SPHERE,
			"shape_size": Vector3(0.4, 0, 0), "lift": 1.1, "direction": Vector3.UP, "spread": 30.0, "speed": Vector2(1.5, 3.0),
			"gravity": -2.0, "size_pixels": Vector2(1, 2), "glows": true}),
	]


func _fireball() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(FIRE, FIRE_CORE)
	look.trail = [
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE_DARK), "amount": 30, "lifetime": 0.45, "one_shot": false,
			"direction": Vector3.UP, "spread": 180.0, "speed": Vector2(0.2, 0.8), "gravity": 1.5, "size_pixels": Vector2(2, 4),
			"shrink": true, "glows": true}),
		_layer({"color_start": _fade(SMOKE, 0.7), "color_end": _fade(SMOKE), "amount": 12, "lifetime": 0.8, "one_shot": false,
			"direction": Vector3.UP, "spread": 60.0, "speed": Vector2(0.2, 0.6), "gravity": 0.8, "size_pixels": Vector2(3, 5)}),
	]
	look.impact = [
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE_DARK), "amount": 40, "lifetime": 0.45, "shape": ParticleLayer.Shape.SPHERE,
			"shape_size": Vector3(0.3, 0, 0), "lift": 0.5, "direction": Vector3.UP, "spread": 180.0, "speed": Vector2(3.0, 6.0),
			"gravity": 1.0, "damping": 8.0, "size_pixels": Vector2(3, 6), "shrink": true, "glows": true}),
		_layer({"color_start": FIRE, "color_end": _fade(FIRE_DARK), "amount": 24, "lifetime": 0.7, "delay": 0.05,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.5, 0, 0), "lift": 0.3, "direction": Vector3.UP, "spread": 25.0,
			"speed": Vector2(1.5, 3.0), "gravity": 2.0, "size_pixels": Vector2(2, 4), "shrink": true, "glows": true}),
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE), "amount": 24, "lifetime": 1.1, "lift": 0.5,
			"direction": Vector3.UP, "spread": 60.0, "speed": Vector2(3.0, 6.0), "gravity": -7.0, "size_pixels": Vector2(1, 2),
			"glows": true}),
		_layer({"color_start": _fade(SMOKE, 0.75), "color_end": _fade(SMOKE), "amount": 18, "lifetime": 1.4, "delay": 0.1,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.4, 0, 0), "lift": 0.6, "direction": Vector3.UP,
			"spread": 35.0, "speed": Vector2(0.6, 1.4), "gravity": 0.6, "damping": 0.5, "size_pixels": Vector2(5, 8)}),
	]
	look.light_color = FIRE
	look.light_energy = 4.0
	look.light_range = 2.5
	look.light_time = 0.45
	look.mark_color = Color(0.08, 0.06, 0.05, 0.55)
	look.mark_time = 3.0
	look.shake = 0.12
	look.shake_time = 0.25
	look.hit_stop = 0.05
	return look


func _cutting_wave() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(WATER, WATER_LIGHT)
	look.impact = [
		_layer({"color_start": WATER_LIGHT, "color_end": _fade(WATER), "amount": 80, "lifetime": 0.55, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(1.0, 0.2, 0.02), "lift": 0.1, "direction": Vector3(0, 1, 0.4),
			"spread": 20.0, "speed": Vector2(2.5, 4.5), "gravity": -11.0, "size_pixels": Vector2(2, 3), "glows": true}),
		_layer({"color_start": _fade(WATER, 0.85), "color_end": _fade(WATER_DEEP), "amount": 60, "lifetime": 0.35, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(0.9, 0.5, 0.02), "lift": 0.35, "direction": Vector3(0, 0.3, 1),
			"spread": 10.0, "speed": Vector2(1.0, 2.0), "size_pixels": Vector2(4, 7), "shrink": true, "glows": true}),
		_layer({"color_start": WATER_LIGHT, "color_end": _fade(WATER), "amount": 30, "lifetime": 0.8, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(1.0, 0.3, 0.02), "lift": 0.5, "direction": Vector3.UP,
			"spread": 50.0, "speed": Vector2(1.0, 2.5), "gravity": -10.0, "size_pixels": Vector2(1, 2), "glows": true}),
	]
	look.sweep_time = 0.45
	look.light_color = WATER
	look.light_energy = 1.5
	look.light_range = 2.0
	look.light_time = 0.6
	look.mark_color = Color(0.1, 0.18, 0.26, 0.4)
	look.mark_time = 2.0
	look.shake = 0.05
	look.shake_time = 0.2
	look.hit_stop = 0.04
	return look


func _earth_collapse() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(EARTH, DUST)
	look.impact = [
		_layer({"color_start": EARTH, "color_end": _fade(EARTH_DARK, 0.6), "amount": 34, "lifetime": 0.95,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.6, 0.1, 0.7), "lift": 0.1, "direction": Vector3.UP,
			"spread": 22.0, "speed": Vector2(4.5, 7.5), "gravity": -20.0, "size_pixels": Vector2(4, 7)}),
		_layer({"color_start": _fade(DUST, 0.8), "color_end": _fade(DUST), "amount": 46, "lifetime": 0.8,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.25, 0.05, 0.0), "lift": 0.15, "direction": Vector3.UP,
			"spread": 40.0, "speed": Vector2(0.5, 1.0), "radial": 9.0, "damping": 4.0, "size_pixels": Vector2(4, 7)}),
		_layer({"color_start": EARTH_DARK, "color_end": EARTH_DARK, "amount": 30, "lifetime": 0.7,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.6, 0, 0), "lift": 0.2, "direction": Vector3.UP,
			"spread": 45.0, "speed": Vector2(2.0, 4.0), "gravity": -14.0, "size_pixels": Vector2(1, 2)}),
	]
	look.mark_color = Color(0.12, 0.09, 0.06, 0.5)
	look.mark_time = 2.5
	look.shake = 0.28
	look.shake_time = 0.4
	look.hit_stop = 0.07
	return look


func _air_gust() -> SpellLook:
	var look := SpellLook.new()
	look.cast = [
		_layer({"color_start": AIR, "color_end": _fade(AIR_PALE), "amount": 20, "lifetime": 0.5, "shape": ParticleLayer.Shape.RING,
			"shape_size": Vector3(0.7, 0.3, 0.8), "lift": 0.6, "direction": Vector3.UP, "spread": 10.0, "speed": Vector2(0.5, 1.0),
			"size_pixels": Vector2(1, 2), "stretch": 4.0, "spin": 2.0, "glows": true}),
	]
	look.impact = [
		_layer({"color_start": _fade(AIR, 0.95), "color_end": _fade(AIR_PALE), "amount": 34, "lifetime": 0.42, "lift": 0.9,
			"direction": Vector3(0, 0, 1), "spread": 30.0, "speed": Vector2(10.0, 15.0), "damping": 12.0, "size_pixels": Vector2(1, 2),
			"stretch": 7.0, "glows": true}),
		_layer({"color_start": _fade(AIR, 0.45), "color_end": _fade(AIR), "amount": 18, "lifetime": 0.55, "lift": 0.7,
			"direction": Vector3(0, 0.1, 1), "spread": 30.0, "speed": Vector2(5.0, 8.0), "damping": 6.0, "size_pixels": Vector2(4, 7),
			"glows": true}),
	]
	# O vento nos pés de Nate enquanto ele está mais rápido.
	look.lasting = [
		_layer({"color_start": _fade(AIR, 0.7), "color_end": _fade(AIR), "amount": 14, "lifetime": 0.35, "one_shot": false,
			"lift": 0.15, "direction": Vector3.UP, "spread": 70.0, "speed": Vector2(0.4, 1.0), "size_pixels": Vector2(1, 2),
			"stretch": 4.0, "glows": true}),
	]
	look.shake = 0.04
	look.shake_time = 0.15
	return look


func _vapor() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(FIRE, WATER)
	look.impact = [
		_layer({"color_start": _fade(STEAM, 0.8), "color_end": _fade(STEAM), "amount": 30, "lifetime": 0.8,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.4, 0, 0), "lift": 0.5, "direction": Vector3.UP,
			"spread": 180.0, "speed": Vector2(1.5, 3.0), "damping": 3.0, "size_pixels": Vector2(5, 9), "glows": true}),
	]
	look.lasting = [
		_layer({"color_start": _fade(STEAM, 0.55), "color_end": _fade(STEAM), "amount": 46, "lifetime": 1.7, "one_shot": false,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.8, 0, 0), "lift": 0.4, "direction": Vector3.UP,
			"spread": 25.0, "speed": Vector2(0.3, 0.8), "gravity": 0.5, "size_pixels": Vector2(5, 10), "glows": true}),
		_layer({"color_start": FIRE, "color_end": _fade(FIRE_DARK), "amount": 10, "lifetime": 0.7, "one_shot": false,
			"shape": ParticleLayer.Shape.SPHERE, "shape_size": Vector3(0.6, 0, 0), "lift": 0.3, "direction": Vector3.UP,
			"spread": 30.0, "speed": Vector2(0.8, 1.6), "size_pixels": Vector2(1, 2), "glows": true}),
	]
	look.light_color = Color(1.0, 0.78, 0.65)
	look.light_energy = 1.2
	look.light_range = 1.6
	look.light_time = 0.4
	return look


func _magma() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(LAVA, EARTH)
	look.impact = [
		_layer({"color_start": LAVA_CORE, "color_end": _fade(FIRE_DARK, 0.9), "amount": 80, "lifetime": 0.85, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(0.8, 0.1, 0.03), "lift": 0.05, "direction": Vector3.UP,
			"spread": 14.0, "speed": Vector2(4.0, 7.5), "gravity": -16.0, "size_pixels": Vector2(3, 6), "shrink": true, "glows": true}),
		_layer({"color_start": ROCK, "color_end": ROCK, "amount": 26, "lifetime": 1.0, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(0.8, 0.1, 0.03), "lift": 0.05, "direction": Vector3.UP,
			"spread": 30.0, "speed": Vector2(3.0, 6.0), "gravity": -18.0, "size_pixels": Vector2(4, 6)}),
		_layer({"color_start": _fade(SMOKE, 0.7), "color_end": _fade(SMOKE), "amount": 22, "lifetime": 1.5, "one_shot": false,
			"shape": ParticleLayer.Shape.BOX, "shape_size": Vector3(0.8, 0.2, 0.03), "lift": 0.4, "direction": Vector3.UP,
			"spread": 20.0, "speed": Vector2(0.8, 1.6), "gravity": 0.6, "size_pixels": Vector2(6, 9)}),
	]
	look.sweep_time = 0.35
	look.light_color = LAVA
	look.light_energy = 3.5
	look.light_range = 3.0
	look.light_time = 0.7
	look.mark_color = Color(1.0, 0.42, 0.1, 0.85)
	look.mark_time = 2.2
	look.mark_glows = true
	look.shake = 0.22
	look.shake_time = 0.45
	look.hit_stop = 0.06
	return look


func _fire_storm() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(FIRE, AIR)
	look.impact = [
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE_DARK), "amount": 36, "lifetime": 0.5,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.5, 0.1, 0.6), "lift": 0.2, "direction": Vector3.UP,
			"spread": 15.0, "speed": Vector2(2.0, 4.0), "radial": 6.0, "size_pixels": Vector2(3, 5), "shrink": true, "glows": true}),
	]
	look.lasting = [
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE_DARK), "amount": 70, "lifetime": 0.7, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.75, 0.6, 0.6), "lift": 0.3, "direction": Vector3.UP,
			"spread": 10.0, "speed": Vector2(1.2, 2.6), "gravity": 1.0, "size_pixels": Vector2(3, 6), "shrink": true, "spin": 1.2,
			"glows": true}),
		_layer({"color_start": FIRE_CORE, "color_end": _fade(FIRE), "amount": 24, "lifetime": 1.0, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.85, 1.0, 0.5), "lift": 0.6, "direction": Vector3.UP,
			"spread": 20.0, "speed": Vector2(0.6, 1.4), "size_pixels": Vector2(1, 2), "spin": 1.6, "glows": true}),
	]
	look.light_color = FIRE
	look.light_energy = 2.0
	look.light_range = 1.6
	look.light_time = 0.4
	look.mark_color = Color(0.1, 0.07, 0.05, 0.4)
	look.mark_time = 1.0
	look.shake = 0.06
	look.shake_time = 0.2
	return look


func _ice() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(ICE, ICE_DEEP)
	look.impact = [
		_layer({"color_start": WATER_LIGHT, "color_end": _fade(ICE_DEEP), "amount": 44, "lifetime": 0.5, "lift": 0.8,
			"direction": Vector3(0, 0.05, 1), "spread": 30.0, "speed": Vector2(9.0, 13.0), "damping": 7.0, "size_pixels": Vector2(2, 3),
			"stretch": 3.0, "glows": true}),
		_layer({"color_start": _fade(ICE, 0.55), "color_end": _fade(ICE), "amount": 30, "lifetime": 0.9, "lift": 0.6,
			"direction": Vector3(0, 0.05, 1), "spread": 30.0, "speed": Vector2(3.0, 6.0), "damping": 4.0, "size_pixels": Vector2(5, 9),
			"glows": true}),
	]
	look.light_color = Color(0.7, 0.9, 1.0)
	look.light_energy = 1.6
	look.light_range = 0.4
	look.light_time = 0.35
	look.mark_color = Color(0.85, 0.95, 1.0, 0.45)
	look.mark_time = 2.5
	look.mark_glows = true
	look.shake = 0.08
	look.shake_time = 0.2
	look.hit_stop = 0.05
	return look


func _mud() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(MUD_LIGHT, WATER)
	look.impact = [
		_layer({"color_start": MUD, "color_end": MUD, "amount": 34, "lifetime": 0.75, "shape": ParticleLayer.Shape.SPHERE,
			"shape_size": Vector3(0.5, 0, 0), "lift": 0.3, "direction": Vector3.UP, "spread": 55.0, "speed": Vector2(2.0, 4.5),
			"gravity": -13.0, "size_pixels": Vector2(3, 5)}),
	]
	look.lasting = [
		_layer({"color_start": MUD_LIGHT, "color_end": _fade(MUD_LIGHT, 0.6), "amount": 16, "lifetime": 0.9, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.85, 0.05, 0.0), "lift": 0.05, "direction": Vector3.UP,
			"spread": 8.0, "speed": Vector2(0.2, 0.5), "size_pixels": Vector2(2, 4), "shrink": true}),
		_layer({"color_start": MUD, "color_end": MUD, "amount": 8, "lifetime": 0.6, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(0.85, 0.05, 0.0), "lift": 0.05, "direction": Vector3.UP,
			"spread": 30.0, "speed": Vector2(1.0, 2.0), "gravity": -10.0, "size_pixels": Vector2(1, 2)}),
	]
	look.mark_color = Color(0.28, 0.2, 0.12, 0.85)
	look.mark_time = 0.8
	look.shake = 0.04
	look.shake_time = 0.15
	return look


func _sand_shield() -> SpellLook:
	var look := SpellLook.new()
	look.cast = _aura(SAND, AIR)
	look.impact = [
		_layer({"color_start": SAND, "color_end": _fade(SAND_DARK), "amount": 30, "lifetime": 0.5, "shape": ParticleLayer.Shape.RING,
			"shape_size": Vector3(0.6, 0.1, 0.5), "lift": 0.2, "direction": Vector3.UP, "spread": 20.0, "speed": Vector2(1.5, 3.0),
			"radial": 4.0, "size_pixels": Vector2(1, 3)}),
	]
	look.lasting = [
		_layer({"color_start": _fade(SAND, 0.95), "color_end": _fade(SAND_DARK), "amount": 60, "lifetime": 0.8, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(1.0, 1.4, 0.85), "lift": 0.8, "direction": Vector3.UP,
			"spread": 10.0, "speed": Vector2(0.2, 0.6), "size_pixels": Vector2(1, 2), "spin": 1.4}),
		_layer({"color_start": SAND_DARK, "color_end": _fade(SAND_DARK), "amount": 16, "lifetime": 1.0, "one_shot": false,
			"shape": ParticleLayer.Shape.RING, "shape_size": Vector3(1.0, 1.0, 0.8), "lift": 0.8, "direction": Vector3.UP,
			"spread": 10.0, "speed": Vector2(0.1, 0.3), "size_pixels": Vector2(3, 4), "spin": 0.9}),
	]
	return look
