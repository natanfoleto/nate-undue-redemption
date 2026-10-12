@tool
class_name ModelData
extends Resource
## Modelo blocado: a lista de caixas e a textura (12-tecnico). Montado pelo BlockModel.

## Textura no molde de caixa. Sem ela, cada caixa usa a própria cor (caixa lisa).
@export var texture: Texture2D:
	set(value):
		texture = value
		emit_changed()
## Caixas do modelo. Os nomes não se repetem.
@export var boxes: Array[BoxData] = []:
	set(value):
		for box in boxes:
			if box and box.changed.is_connected(emit_changed):
				box.changed.disconnect(emit_changed)
		boxes = value
		# Repassa a mudança de qualquer caixa, para a prévia montar de novo.
		for box in boxes:
			if box and not box.changed.is_connected(emit_changed):
				box.changed.connect(emit_changed)
		emit_changed()


## Textura das caixas lisas: a região de cada caixa pintada com a cor dela.
func make_flat_texture() -> ImageTexture:
	var extent := Vector2i.ONE
	for box in boxes:
		if box:
			for rect: Rect2i in box.face_rects().values():
				extent = extent.max(rect.end)
	var image := Image.create_empty(extent.x, extent.y, false, Image.FORMAT_RGBA8)
	for box in boxes:
		if box:
			for rect: Rect2i in box.face_rects().values():
				image.fill_rect(rect, box.color)
	return ImageTexture.create_from_image(image)
