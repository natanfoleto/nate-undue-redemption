class_name Sanctuary
extends Interactable
## Santuário (08-mapa, 02-core-loop): interagir abre o menu com Descansar e Viajar. Descansar enche a vida e o
## frasco, salva e vira o ponto de retorno. Na primeira visita ele acende e mostra a memória; o primeiro
## santuário dá o frasco.

const MENU_SCENE := "res://ui/sanctuary_menu.tscn"

@export var data: SanctuaryData
## Dá o frasco na primeira visita (S1).
@export var gives_flask := false
## Cor e força do brilho dos padrões acesos, a força da luz e o tempo para acender, em segundos.
@export var glow_color := Color.WHITE
@export var lit_glow := 0.0
@export var light_energy := 0.0
@export var light_up_time := 0.0

@onready var _model: BlockModel = $Model
@onready var _light: OmniLight3D = $Light


func _ready() -> void:
	super._ready()
	# O ponto onde Nate aparece, na frente do santuário, tem o identificador dele.
	($SpawnPoint as RespawnPoint).id = data.id()
	_show_lit(1.0 if _visited() else 0.0)


func interact() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	if not _visited():
		await _first_visit(player)
	GameState.set_respawn_point(data.id())
	var menu := (load(MENU_SCENE) as PackedScene).instantiate() as SanctuaryMenu
	get_tree().current_scene.add_child(menu)
	menu.open(self)
	var choice: SanctuaryData = await menu.closed
	if choice:
		GameState.set_respawn_point(choice.id(), choice.area)
		GameState.change_area(choice.area, choice.id())
		return
	player.set_cinematic(false)


## Descanso (02-core-loop): a tela escurece, vida e frasco enchem e o jogo salva.
func rest() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	await GameState.fade_out()
	player.rest()
	SaveSystem.save()
	GameState.fade_in()


func _first_visit(player: Player) -> void:
	# Tudo gravado antes de qualquer espera; a visita por último, para a primeira visita voltar se o jogo fechar.
	var new_flask := gives_flask and not GameState.has_flask()
	if new_flask:
		SaveSystem.record(SaveSystem.ITEMS, GameState.FLASK)
	GameState.set_respawn_point(data.id())
	SaveSystem.record(SaveSystem.SANCTUARIES, data.id())
	var tween := create_tween()
	tween.tween_method(_show_lit, 0.0, 1.0, light_up_time)
	await tween.finished
	if new_flask:
		ItemFound.show_name(self, &"ITEM_FLASK")
		Events.item_picked.emit(GameState.FLASK)
	player.rest()
	if data.memory != "":
		var memory := (load(data.memory) as PackedScene).instantiate() as MemoryScene
		get_tree().current_scene.add_child(memory)
		await memory.finished


func _visited() -> bool:
	return SaveSystem.has_record(SaveSystem.SANCTUARIES, data.id())


func _show_lit(weight: float) -> void:
	_model.set_part_glow(&"glow", glow_color, weight * lit_glow)
	_light.visible = weight > 0.0
	_light.light_energy = weight * light_energy
