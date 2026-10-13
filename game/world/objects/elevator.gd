class_name Elevator
extends Interactable
## Elevador velho da mina (08-mapa): liga a Mina e o Bosque de Fungos. Com Nate em cima, interagir faz a
## viagem. Na primeira descida ele quebra na chegada ao Bosque; consertado perto do S1, vira atalho entre o S1
## e a Mina. Cada área tem o seu lado do elevador.

## Área do outro lado e o ponto onde Nate chega lá.
@export_file("*.tscn") var destination: String
@export var destination_arrival: StringName
## Ponto de chegada deste lado (o RespawnPoint em cima da plataforma).
@export var arrival_id: StringName
## Para onde a viagem vai: -1 desce, 1 sobe.
@export var travel_direction := -1
## Quanto a plataforma anda, em blocos, e em quanto tempo, em segundos, antes de a tela escurecer.
@export var depth := 0.0
@export var travel_time := 0.0
## Identificador do conserto, o mesmo dos dois lados.
@export var repair_id: StringName
## Este lado fica quebrado até o conserto (o Bosque).
@export var needs_repair := false
## Inclinação da plataforma quebrada, em graus; tempo da batida e do conserto, em segundos.
@export var broken_tilt := 0.0
@export var crash_time := 0.0
@export var repair_time := 0.0
## Cor e raio da poeira da batida, em blocos, e a aparência dela.
@export var dust_color := Color.WHITE
@export var dust_radius := 0.0
@export var dust_look: EffectLook

var _busy := false

@onready var _platform: Node3D = $Platform


func _ready() -> void:
	super._ready()
	($Arrival as RespawnPoint).id = arrival_id
	if needs_repair and not is_repaired():
		_platform.rotation_degrees.z = broken_tilt
	if arrival_id != &"" and GameState.arrival == arrival_id:
		# Depois de a área pôr Nate em cima da plataforma.
		_arrive.call_deferred()


func can_interact() -> bool:
	return not _busy


func is_repaired() -> bool:
	return SaveSystem.has_record(SaveSystem.OPENED, repair_id)


func interact() -> void:
	if needs_repair and not is_repaired():
		_repair()
	else:
		_travel()


func _repair() -> void:
	SaveSystem.record(SaveSystem.OPENED, repair_id)
	_busy = true
	var tween := create_tween()
	tween.tween_property(_platform, ^"rotation_degrees:z", 0.0, repair_time)
	tween.tween_callback(func() -> void: _busy = false)


func _travel() -> void:
	_busy = true
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	var tween := create_tween().set_parallel()
	tween.tween_property(_platform, ^"position:y", _platform.position.y + travel_direction * depth, travel_time)
	tween.tween_property(player, ^"global_position:y", player.global_position.y + travel_direction * depth, travel_time)
	await tween.finished
	GameState.change_area(destination, destination_arrival)


# Nate chega em cima da plataforma, vindo do outro lado. Na primeira descida, ela quebra ao chegar.
func _arrive() -> void:
	_busy = true
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	var rest_y := _platform.position.y
	var player_y := player.global_position.y
	var start := travel_direction * depth / 2.0
	_platform.position.y = rest_y + start
	player.global_position.y = player_y + start
	var tween := create_tween().set_parallel()
	tween.tween_property(_platform, ^"position:y", rest_y, travel_time / 2.0)
	tween.tween_property(player, ^"global_position:y", player_y, travel_time / 2.0)
	await tween.finished
	if needs_repair and not is_repaired():
		# A queda: a plataforma bate, entorta e solta poeira.
		var crash := create_tween()
		crash.tween_property(_platform, ^"rotation_degrees:z", broken_tilt, crash_time)
		SpellEffects.burst(get_parent(), global_position, dust_color, dust_radius, dust_look)
		await crash.finished
	player.set_cinematic(false)
	_busy = false
