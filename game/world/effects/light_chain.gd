class_name LightChain
extends MultiMeshInstance3D
## Corrente de luz (07-chefes/boiuna, 10-arte-audio): elos de jade acesos, de um ponto a outro, com a barriga para
## baixo. Os pontos podem mudar a cada quadro (a Boiúna se mexe). [member fill] diz quanto da corrente já existe, a
## partir do começo: ela nasce do muiraquitã até o pilar enquanto Nate segura, e do pilar até a Boiúna.

## Tamanho de cada elo, em blocos, e a distância entre um elo e o próximo.
@export var link_size := Vector3.ONE
@export var link_spacing := 1.0
## Quanto o meio da corrente desce, em blocos.
@export var sag := 0.0
## Cor e força do brilho dos elos.
@export var color := Color.WHITE
@export var glow := 1.0
## Quantos elos cabem, no máximo.
@export var max_links := 1

var from := Vector3.ZERO
var to := Vector3.ZERO
var fill := 1.0


func _ready() -> void:
	# Os elos ficam no mundo: o nó vai para a origem, sem seguir quem o tem.
	top_level = true
	global_transform = Transform3D.IDENTITY
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(color.r * glow, color.g * glow, color.b * glow)
	var mesh := BoxMesh.new()
	mesh.size = link_size
	mesh.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = max_links
	multimesh.visible_instance_count = 0


func _process(_delta: float) -> void:
	if not visible:
		return
	var length := from.distance_to(to)
	var count := mini(floori(length * clampf(fill, 0.0, 1.0) / link_spacing), max_links)
	multimesh.visible_instance_count = count
	if count == 0:
		return
	for i in count:
		var t := (i + 0.5) * link_spacing / length
		var here := _point(t)
		var ahead := _point(minf(t + 0.01, 1.0)) - _point(maxf(t - 0.01, 0.0))
		var along := ahead.normalized() if not ahead.is_zero_approx() else Vector3.FORWARD
		var side := along.cross(Vector3.UP)
		if side.is_zero_approx():
			side = Vector3.RIGHT
		side = side.normalized()
		var up := side.cross(along).normalized()
		# Elos alternados, um deitado e o próximo em pé, como numa corrente de verdade.
		var basis := Basis(side, up, -along) if i % 2 == 0 else Basis(up, -side, -along)
		multimesh.set_instance_transform(i, Transform3D(basis.orthonormalized(), here))


# Um ponto da corrente: a reta entre as pontas, descendo no meio como uma parábola.
func _point(t: float) -> Vector3:
	return from.lerp(to, t) + Vector3.DOWN * sag * 4.0 * t * (1.0 - t)
