class_name CellLook
extends Resource
## Aparência dos espaços de item (09-interface, 10-arte-audio), a mesma na barra fixa e no inventário. O arquivo de
## dados fica em game/data/ui/.

## Lado do espaço e quantas vezes o ícone de 16 px é ampliado, em pixels da tela.
@export var size := 0
@export var icon_scale := 1
## Fundo do espaço.
@export var back_color := Color.BLACK
## Molduras (10-arte-audio): marajoara em verde-jade, com brilho; comum em cinza; espaço vazio, apagado.
@export var marajoara_color := Color.WHITE
@export var common_color := Color.WHITE
@export var empty_color := Color.WHITE
@export var frame_width := 0
@export var glow_width := 0
## O espaço da mão (o item que Nate segura): moldura dourada e mais grossa.
@export var hand_color := Color.WHITE
@export var hand_width := 0
## O espaço em foco ou embaixo do mouse, no inventário.
@export var focus_color := Color.WHITE
## Transparência do ícone do item que está sendo levado para outro espaço.
@export var carried_alpha := 0.0
## Tamanho do número do espaço e das cargas, a distância deles até a moldura e o contorno escuro, em pixels da tela.
@export var font_size := 0
@export var text_margin := 0
@export var text_outline := 0
