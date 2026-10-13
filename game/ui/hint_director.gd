class_name HintDirector
extends Node
## Decide quando cada dica de controle aparece (09-interface): quando uma ação nova surge, o ícone do botão
## aparece perto de Nate e some depois que ele a usa. A dica usada não volta, nem depois de fechar o jogo.

## Dicas do começo (o prólogo ensina andar, o combo e a esquiva).
@export var start_hints: Array[HintData] = []
## Dica que aparece ao pegar um item (o tiro, com o estilingue).
@export var item_hints: Dictionary[StringName, HintData] = {}
## Dica que aparece na primeira vez que Nate chega perto de algo com que dá para interagir.
@export var interact_hint: HintData
@export var hints: ControlHints
@export var hint_scene: PackedScene

var _interact_shown := false


func _ready() -> void:
	for hint in start_hints:
		_show(hint)
	# A dica de um item que Nate já tem volta enquanto não for usada (o jogo pode ter fechado antes).
	for item_id in item_hints:
		if SaveSystem.has_record(SaveSystem.ITEMS, item_id) or SaveSystem.has_record(SaveSystem.ELEMENTS, item_id):
			_show(item_hints[item_id])
	Events.item_picked.connect(_on_item_picked)


func _physics_process(_delta: float) -> void:
	if _interact_shown or interact_hint == null or _was_used(interact_hint):
		return
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return
	for object: Interactable in get_tree().get_nodes_in_group(&"interactables"):
		var offset := object.global_position - player.global_position
		if object.can_interact() and Vector2(offset.x, offset.z).length() <= object.reach:
			_interact_shown = true
			_show(interact_hint)
			return


func _on_item_picked(item_id: StringName) -> void:
	if item_hints.has(item_id):
		_show(item_hints[item_id])


func _show(hint: HintData) -> void:
	if _was_used(hint):
		return
	var button_hint := hint_scene.instantiate() as ButtonHint
	button_hint.actions = hint.actions
	button_hint.text_key = hint.text_key
	button_hint.together = hint.together
	button_hint.used.connect(_on_used)
	hints.add_hint(button_hint)


func _on_used(text_key: StringName) -> void:
	var used: Array = SaveSystem.data.get_or_add("hints", [])
	if String(text_key) not in used:
		used.append(String(text_key))
		SaveSystem.save()


func _was_used(hint: HintData) -> bool:
	return String(hint.text_key) in (SaveSystem.data.get("hints", []) as Array)
