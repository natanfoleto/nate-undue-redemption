class_name ItemPickup
extends Node3D
## Item no chão (05-itens): um feixe de luz o marca de longe, e Nate o pega ao passar por ele.

## Identificador único no mapa.
@export var save_id: StringName
## Identificador do item (o nome do arquivo em game/data/items/) e o espaço dele.
@export var item_id: StringName
@export var item_slot: String
## Distância em que Nate pega o item, em blocos.
@export var pickup_radius := 0.0


func _ready() -> void:
	if SaveSystem.has_record(SaveSystem.OPENED, save_id):
		queue_free()
		return
	var item: Resource = load(GameState.ITEMS_FOLDER + item_id + ".tres")
	($BlockModel as BlockModel).model = item.get(&"model")


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return
	var offset := player.global_position - global_position
	if Vector2(offset.x, offset.z).length() > pickup_radius:
		return
	SaveSystem.record(SaveSystem.OPENED, save_id)
	GameState.pick_up(item_id, item_slot)
	ItemFound.show_found(self, item_id)
	queue_free()
