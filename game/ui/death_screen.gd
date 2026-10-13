class_name DeathScreen
extends ColorRect
## Morte (09-interface): Nate cai, a tela escurece e ele reaparece no ponto de retorno, sem menu.
## Os tempos vêm do Balance.

var _tween: Tween


func _ready() -> void:
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.player_died.connect(_on_player_died)
	Events.player_respawned.connect(_on_player_respawned)


func _on_player_died() -> void:
	_fade(1.0, Balance.player.death_time)


func _on_player_respawned() -> void:
	_fade(0.0, Balance.player.respawn_fade_time)


func _fade(alpha: float, time: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"modulate:a", alpha, time)
