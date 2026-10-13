class_name CameraStats
extends Resource
## Ângulo e enquadramento da câmera do jogo (12-tecnico). O arquivo de dados fica em game/data/balance/.

## Inclinação para baixo, em graus (0 olha reto para a frente; 90, de cima).
@export var pitch := 0.0
## Giro em volta do eixo vertical, em graus.
@export var yaw := 0.0
## Altura do que aparece na tela, em blocos.
@export var view_height := 0.0
## Distância até Nate, em blocos. Só precisa deixar a câmera longe das paredes; não muda o enquadramento.
@export var distance := 0.0
