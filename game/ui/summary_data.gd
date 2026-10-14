class_name SummaryData
extends Resource
## O que o resumo do fim conta (09-interface): quantas melhorias e pergaminhos há no mapa e quais itens contam como
## equipamento achado (os 5 do mapa, sem a espada inicial). Os murais contam pelo Mural.COUNT. O arquivo fica em
## game/data/ui/.

@export var upgrades_total := 0
@export var scrolls_total := 0
@export var equipment: Array[StringName] = []
