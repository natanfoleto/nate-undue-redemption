extends Node3D
## Lampião da Mina (10-arte-audio): luz amarela num poste; o vidro brilha.

## Brilho do vidro, de 0 a 1.
@export var glow := 0.0


func _ready() -> void:
	($Lantern as BlockModel).set_glow(glow)
