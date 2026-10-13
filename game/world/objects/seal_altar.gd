class_name SealAltar
extends Interactable
## O Selo (05-itens): a lasca do muiraquitã, escondida pelo irmão traidor na sala do Selo. Pegar faz a lasca se
## encaixar, e o muiraquitã fica inteiro. O Selo não tem poder de combate.

@onready var _seal: Node3D = $Seal


func can_interact() -> bool:
	return _seal.visible


func interact() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	# O Selo primeiro: se o jogo fechar no meio, o altar ainda o mostra.
	SaveSystem.record(SaveSystem.ITEMS, GameState.SEAL)
	_mark_done()
	_seal.visible = false
	ItemFound.show_name(self, &"ITEM_SEAL")
	await player.fit_seal()
	player.set_cinematic(false)


func _restore_done() -> void:
	_seal.visible = false
