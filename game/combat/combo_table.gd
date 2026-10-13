class_name ComboTable
extends Resource
## As combinações de dois elementos (05-itens): a chave junta os dois identificadores em ordem alfabética,
## como "fire+water".

@export var combos: Dictionary[String, SpellData] = {}
## Ícone de cada combinação, com a mesma chave.
@export var icons: Dictionary[String, Texture2D] = {}


static func key(first: StringName, second: StringName) -> String:
	var pair := [String(first), String(second)]
	pair.sort()
	return "+".join(pair)


func find(first: StringName, second: StringName) -> SpellData:
	return combos.get(key(first, second))
