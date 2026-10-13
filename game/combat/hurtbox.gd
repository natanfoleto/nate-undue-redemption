class_name Hurtbox
extends Node3D
## Onde a entidade recebe golpes (12-tecnico): um círculo no chão em volta dela.
## Quem recebe é o pai, que precisa ter take_hit(hit: Hit).

enum Faction { PLAYER, ENEMY }

@export var faction := Faction.ENEMY
## Raio do círculo, em blocos.
@export var radius := 0.0

## Quem recebe os golpes.
var receiver: Node3D:
	get:
		return get_parent() as Node3D


func _enter_tree() -> void:
	add_to_group(group_for(faction))


## Grupo com os círculos de uma facção, onde os golpes procuram alvos.
static func group_for(target_faction: Faction) -> StringName:
	return &"hurtbox_player" if target_faction == Faction.PLAYER else &"hurtbox_enemy"
