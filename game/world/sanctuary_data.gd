class_name SanctuaryData
extends Resource
## Um santuário (08-mapa): o nome na lista da viagem rápida, a área onde fica e a memória da primeira visita.
## O identificador é o nome do arquivo, em game/data/sanctuaries/.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Cena da área onde ele fica.
@export_file("*.tscn") var area: String
## Cena da memória mostrada na primeira visita (10-arte-audio); vazia, nenhuma.
@export_file("*.tscn") var memory: String


func id() -> StringName:
	return StringName(resource_path.get_file().get_basename())
