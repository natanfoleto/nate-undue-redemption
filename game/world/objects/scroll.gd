class_name Scroll
extends Interactable
## Pergaminho (05-itens): Nate lê (interagir) e aprende o elemento na hora. O rolo se abre na tela com o
## desenho do elemento, sem texto. O primeiro acorda o muiraquitã, que passa a dar a Luz Ancestral.

const VIEW_SCENE := "res://ui/scroll_view.tscn"

## O elemento que ele ensina (o nome do arquivo em game/data/elements/).
@export var element_id: StringName


func can_interact() -> bool:
	return visible


func interact() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	var first := not GameState.has_light()
	_set_read()
	var view := (load(VIEW_SCENE) as PackedScene).instantiate() as ScrollView
	AudioManager.play(&"scroll_open")
	get_tree().current_scene.add_child(view)
	await view.show_element(load(GameState.ELEMENTS_FOLDER + element_id + ".tres"))
	# O elemento primeiro: se o jogo fechar com o rolo aberto, o pergaminho continua lá para ler de novo.
	GameState.learn(element_id)
	_mark_done()
	if first:
		await player.awaken_amulet()
	player.set_cinematic(false)


func _restore_done() -> void:
	_set_read()


# Lido, o pergaminho some e não segura mais quem anda nem os tiros.
func _set_read() -> void:
	visible = false
	($CollisionShape3D as CollisionShape3D).set_deferred(&"disabled", true)
