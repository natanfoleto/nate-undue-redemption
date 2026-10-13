extends Node
## Último dispositivo usado, para os ícones de botão e para a mira, e botões trocados pelo jogador (12-tecnico).
## Os botões padrão ficam no mapa de entrada do projeto.

signal device_changed(device: Device)

enum Device { KEYBOARD_MOUSE, XBOX, PLAYSTATION }

## Código de fabricante da Sony no USB.
const SONY_VENDOR_ID := 1356
const PLAYSTATION_NAMES: Array[String] = ["playstation", "dualsense", "dualshock", "ps3", "ps4", "ps5", "sony"]

var device := Device.KEYBOARD_MOUSE

var _icon_sets: Dictionary[Device, ButtonIcons] = {
	Device.KEYBOARD_MOUSE: load("res://data/ui/buttons_keyboard_mouse.tres"),
	Device.XBOX: load("res://data/ui/buttons_xbox.tres"),
	Device.PLAYSTATION: load("res://data/ui/buttons_playstation.tres"),
}


func is_gamepad() -> bool:
	return device != Device.KEYBOARD_MOUSE


## Ícones dos botões das ações no dispositivo atual, sem repetir: as 4 direções do analógico viram 1 ícone.
func icons_for(actions: Array[StringName]) -> Array[Texture2D]:
	var icon_set := _icon_sets[device]
	var icons: Array[Texture2D] = []
	for action in actions:
		var icon := _icon_for(action, icon_set)
		if icon and icon not in icons:
			icons.append(icon)
	return icons


func _icon_for(action: StringName, icon_set: ButtonIcons) -> Texture2D:
	for event in InputMap.action_get_events(action):
		var icon := icon_set.icon_for(event)
		if icon:
			return icon
	return icon_set.fallback


func _input(event: InputEvent) -> void:
	if not _counts_as_use(event):
		return
	var used := _device_of(event)
	if used != device:
		device = used
		device_changed.emit(device)


# O analógico só conta depois da zona morta de alguma ação, para o ruído do controle não trocar os ícones.
func _counts_as_use(event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		return InputMap.get_actions().any(func(action: StringName) -> bool: return event.is_action_pressed(action))
	return event is InputEventKey or event is InputEventMouseButton \
		or event is InputEventMouseMotion or event is InputEventJoypadButton


func _device_of(event: InputEvent) -> Device:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return Device.PLAYSTATION if _is_playstation(event.device) else Device.XBOX
	return Device.KEYBOARD_MOUSE


func _is_playstation(joypad: int) -> bool:
	if Input.get_joy_info(joypad).get("vendor_id", 0) == SONY_VENDOR_ID:
		return true
	var joy_name := Input.get_joy_name(joypad).to_lower()
	return PLAYSTATION_NAMES.any(func(hint: String) -> bool: return joy_name.contains(hint))
