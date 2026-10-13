class_name Health
extends Node
## Vida de uma entidade (03-regras), em pontos.
## O valor máximo vem dos dados de quem a usa.

signal changed(value: int, max_value: int)
signal died

var max_value := 0
var value := 0


## Começa ou volta com a vida cheia.
func reset(new_max: int) -> void:
	max_value = new_max
	value = new_max
	changed.emit(value, max_value)


## Muda o máximo. A vida a mais chega vazia (armadura) ou cheia, com [param fill] (melhoria); com um
## máximo menor, a vida atual é cortada nele (05-itens).
func set_max(new_max: int, fill := false) -> void:
	var gained := maxi(new_max - max_value, 0) if fill else 0
	value = clampi(value + gained, 0, new_max)
	max_value = new_max
	changed.emit(value, max_value)


func heal(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	value = mini(value + amount, max_value)
	changed.emit(value, max_value)


func damage(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	value = maxi(value - amount, 0)
	changed.emit(value, max_value)
	if value == 0:
		died.emit()


func is_dead() -> bool:
	return value <= 0
