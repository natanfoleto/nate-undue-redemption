class_name ButtonIcons
extends Resource
## Ícones de botão de um tipo de dispositivo (09-interface): cada botão do mapa de entrada aponta para um ícone.
## Os arquivos de dados ficam em game/data/ui/.

## Teclas, pela posição física.
@export var keys: Dictionary[Key, Texture2D] = {}
## Botões do mouse.
@export var mouse_buttons: Dictionary[MouseButton, Texture2D] = {}
## Botões do controle.
@export var joy_buttons: Dictionary[JoyButton, Texture2D] = {}
## Eixos do controle (analógicos e gatilhos).
@export var joy_axes: Dictionary[JoyAxis, Texture2D] = {}
## Ícone da ação que não tem botão neste dispositivo. No teclado e mouse, a mira é o próprio mouse.
@export var fallback: Texture2D


## Ícone de um botão do mapa de entrada, ou nulo se o botão não é deste dispositivo.
func icon_for(event: InputEvent) -> Texture2D:
	if event is InputEventKey:
		return keys.get((event as InputEventKey).physical_keycode)
	if event is InputEventMouseButton:
		return mouse_buttons.get((event as InputEventMouseButton).button_index)
	if event is InputEventJoypadButton:
		return joy_buttons.get((event as InputEventJoypadButton).button_index)
	if event is InputEventJoypadMotion:
		return joy_axes.get((event as InputEventJoypadMotion).axis)
	return null
