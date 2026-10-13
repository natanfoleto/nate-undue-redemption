class_name MainMenu
extends Control
## Menu principal (09-interface): Continuar (quando há jogo salvo), Novo jogo e Sair. Um jogo salvo só;
## "Novo jogo" pede confirmação antes de apagar o jogo salvo. As opções chegam no acabamento.

## A primeira área do jogo.
@export_file("*.tscn") var first_area: String

@onready var _continue: Button = %Continue
@onready var _new_game: Button = %NewGame
@onready var _quit: Button = %Quit
@onready var _confirm: ConfirmationDialog = %ConfirmNewGame


func _ready() -> void:
	%Title.text = tr(&"GAME_TITLE")
	_continue.text = tr(&"MENU_CONTINUE")
	_new_game.text = tr(&"MENU_NEW_GAME")
	_quit.text = tr(&"MENU_QUIT")
	_confirm.title = tr(&"MENU_CONFIRM_TITLE")
	_confirm.dialog_text = tr(&"MENU_CONFIRM_NEW")
	_confirm.ok_button_text = tr(&"MENU_YES")
	_confirm.cancel_button_text = tr(&"MENU_NO")
	_continue.visible = SaveSystem.has_save()
	_continue.pressed.connect(_play)
	_new_game.pressed.connect(_on_new_game)
	_quit.pressed.connect(get_tree().quit)
	_confirm.confirmed.connect(_start_new_game)
	(_continue if _continue.visible else _new_game).grab_focus()


func _on_new_game() -> void:
	if SaveSystem.has_save():
		_confirm.popup_centered()
	else:
		_start_new_game()


func _start_new_game() -> void:
	SaveSystem.new_game()
	_play()


# Continua na área do último ponto de retorno; o jogo novo começa na primeira área.
func _play() -> void:
	var area := GameState.respawn_area()
	get_tree().change_scene_to_file(area if area != "" else first_area)
