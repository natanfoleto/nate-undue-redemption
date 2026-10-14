class_name NatePreview
extends TextureRect
## Nate no inventário (09-interface), como o boneco do inventário do Minecraft: o modelo parado, com o item da mão,
## a armadura vestida e o muiraquitã, virando um pouco para o lado do mouse. Desenhado num mundo 3D só dele, com o
## tamanho que ocupa na tela, para os pixels ficarem nítidos.

## Modelo de Nate e a animação parada.
@export var model: ModelData
@export var idle_animation: AnimationData
## Altura que a câmera mostra e altura do ponto que ela olha, em blocos; inclinação dela para baixo, em graus.
@export var view_height := 0.0
@export var look_height := 0.0
@export var tilt := 0.0
## Distância da câmera até o ponto que ela olha, em blocos (a câmera é ortogonal: só a deixa fora do boneco).
@export var camera_distance := 0.0
## Quanto Nate vira para o lado do mouse, no máximo, em graus, e a rapidez da virada.
@export var turn_limit := 0.0
@export var turn_speed := 0.0
## Luz do ambiente e do sol do boneco, e o giro do sol, em graus (Nate olha para a câmera, para o -z).
@export var ambient_energy := 0.0
@export var sun_energy := 0.0
@export var sun_angles := Vector3.ZERO
## Brilho do muiraquitã aceso (o mesmo do jogo).
@export var amulet_color := Color.WHITE
@export var amulet_glow := 0.0

var _viewport: SubViewport
var _body: BlockModel
var _worn: Array[BlockModel] = []


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	_viewport = SubViewport.new()
	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = ambient_energy
	var world := WorldEnvironment.new()
	world.environment = environment
	_viewport.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = sun_angles
	sun.light_energy = sun_energy
	_viewport.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = view_height
	var target := Vector3(0, look_height, 0)
	var spot := target + Vector3(0, sin(deg_to_rad(tilt)), -cos(deg_to_rad(tilt))) * camera_distance
	camera.transform = Transform3D(Basis.looking_at(target - spot), spot)
	_viewport.add_child(camera)
	_body = BlockModel.new()
	_body.model = model
	var animator := ModelAnimator.new()
	animator.animation = idle_animation
	_body.add_child(animator)
	_viewport.add_child(_body)
	texture = _viewport.get_texture()
	resized.connect(_fit)
	get_viewport().size_changed.connect(_fit)


## Desenha o boneco só com o inventário aberto.
func set_active(on: bool) -> void:
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	if on:
		_fit()


## Veste o boneco como Nate está: o item da mão, a armadura e o muiraquitã (o mesmo jeito do jogo).
func dress(held: Resource, armor: ArmorData) -> void:
	for worn in _worn:
		worn.free()
	_worn.clear()
	if held:
		_wear(held.get(&"model"), &"hand_r" if held is MeleeWeaponData else &"hand_l")
	if armor:
		_wear(armor.model, &"body")
	var chip := _body.get_part(&"muiraquita_chip")
	if chip:
		chip.visible = GameState.has_seal()
	for part in [&"muiraquita", &"muiraquita_chip"]:
		_body.set_part_glow(part, amulet_color, amulet_glow if GameState.has_light() else 0.0)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var center := get_global_rect().get_center()
	var share := clampf((get_global_mouse_position().x - center.x) / size.x, -1.0, 1.0)
	var target := deg_to_rad(turn_limit) * share
	_body.rotation.y = lerp_angle(_body.rotation.y, target, 1.0 - exp(-turn_speed * delta))


func _wear(item_model: ModelData, part_name: StringName) -> void:
	var part := _body.get_part(part_name)
	if item_model == null or part == null:
		return
	var worn := BlockModel.new()
	worn.model = item_model
	part.add_child(worn)
	_worn.append(worn)


# Um ponto do mundo do boneco para cada pixel da tela que ele ocupa.
func _fit() -> void:
	var pixels := size * get_viewport().get_final_transform().get_scale()
	_viewport.size = Vector2i(maxi(1, roundi(pixels.x)), maxi(1, roundi(pixels.y)))
