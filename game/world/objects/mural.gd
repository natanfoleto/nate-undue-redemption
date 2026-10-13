class_name Mural
extends Interactable
## Mural (08-mapa, 09-interface): conta a história sem texto. Na parede, o desenho pequeno; interagir mostra o mural
## grande na tela, e depois ele fica na galeria do menu de pausa.

const VIEW_SCENE := "res://ui/mural_view.tscn"
## Quantos murais o jogo tem (08-mapa).
const COUNT := 7

## O número do mural, de 1 a 7 (08-mapa).
@export var mural_id := 0

@onready var _picture: MeshInstance3D = $Picture


## O desenho de um mural.
static func image(id: int) -> Texture2D:
	return load("res://assets/murals/mural_%d.png" % id)


## O identificador de um mural no jogo salvo.
static func record_id(id: int) -> StringName:
	return StringName("mural_%d" % id)


static func seen(id: int) -> bool:
	return SaveSystem.has_record(SaveSystem.MURALS, record_id(id))


func _ready() -> void:
	super._ready()
	# Cada mural com o próprio material: o da cena é um só para todos, e o último desenho valeria para todos.
	var material := (_picture.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
	material.albedo_texture = image(mural_id)
	_picture.material_override = material


func interact() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	SaveSystem.record(SaveSystem.MURALS, record_id(mural_id))
	var view := (load(VIEW_SCENE) as PackedScene).instantiate() as MuralView
	get_tree().current_scene.add_child(view)
	await view.show_image(image(mural_id))
	player.set_cinematic(false)
