class_name ParticleLayer
extends Resource
## Uma camada de partículas blocadas de um efeito de magia (10-arte-audio): cubinhos, ou riscos esticados no sentido
## em que andam, que saem de um ponto, de uma esfera, de um anel ou de uma caixa, com cor, quantidade, tempo,
## velocidade e gravidade. As formas acompanham o tamanho da área da magia (na aura ao lançar, no rastro do projétil e
## no vento nos pés de Nate, elas valem em blocos); o resto fica em blocos e segundos.

enum Shape { POINT, SPHERE, RING, BOX }

## Cor no começo e no fim da vida de cada cubinho (a transparência muda junto).
@export var color_start := Color.WHITE
@export var color_end := Color.WHITE
## Quantos cubinhos saem e quanto tempo cada um vive, em segundos.
@export var amount := 0
@export var lifetime := 0.0
## Todos de uma vez (um estouro) ou sem parar enquanto o efeito dura.
@export var one_shot := true
## Espera antes de começar, em segundos.
@export var delay := 0.0
## De onde saem. Na esfera, o raio em partes do raio da área (x). No anel, o raio em partes do raio da área (x), a
## altura em blocos (y) e o miolo vazio em partes do raio do anel (z). Na caixa, a largura em partes da largura da
## área (x), a altura em blocos (y) e o comprimento em partes do comprimento da área (z).
@export var shape := Shape.POINT
@export var shape_size := Vector3.ZERO
## Altura do centro sobre o chão, em blocos; e quanto ele vai para a frente, em partes do comprimento da área.
@export var lift := 0.0
@export var forward := 0.0
## Para onde vão (x à direita, y para cima, z para a frente da magia), a abertura em volta disso, em graus, e a
## velocidade, menor e maior, em blocos/s.
@export var direction := Vector3.UP
@export var spread := 0.0
@export var speed := Vector2.ZERO
## Gravidade (positiva sobe), empurrão para longe do centro e freio, em blocos/s².
@export var gravity := 0.0
@export var radial := 0.0
@export var damping := 0.0
## Lado de cada cubinho, menor e maior, em pixels (16 px = 1 bloco); quanto ele fica esticado no sentido em que anda
## (1 é um cubo); e se ele encolhe até sumir.
@export var size_pixels := Vector2.ONE
@export var stretch := 1.0
@export var shrink := false
## Giro do conjunto em volta do centro, em voltas por segundo (os redemoinhos).
@export var spin := 0.0
## Os cubinhos acendem sozinhos (o fogo, a lava, as faíscas e o gelo) e não dependem da luz do lugar.
@export var glows := false


## As partículas desta camada, no tamanho da área (x: raio, y: comprimento, z: largura). Servem às magias
## (SpellEffects, que diz quando cada camada começa) e ao cenário (os esporos do Bosque, que já começam soltando).
func build(area: Vector3) -> CPUParticles3D:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glows:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, stretch, 1.0) / BoxData.PIXELS_PER_BLOCK
	mesh.material = material
	var particles := CPUParticles3D.new()
	particles.mesh = mesh
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = one_shot
	particles.explosiveness = 1.0 if one_shot else 0.0
	# Os que giram ficam presos ao conjunto; os outros ficam no mundo onde saíram (o rastro).
	particles.local_coords = spin != 0.0
	particles.position = Vector3(0.0, lift, -forward * area.y)
	match shape:
		ParticleLayer.Shape.SPHERE:
			particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			particles.emission_sphere_radius = shape_size.x * area.x
		ParticleLayer.Shape.RING:
			particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
			particles.emission_ring_axis = Vector3.UP
			particles.emission_ring_radius = shape_size.x * area.x
			particles.emission_ring_inner_radius = particles.emission_ring_radius * shape_size.z
			particles.emission_ring_height = shape_size.y
		ParticleLayer.Shape.BOX:
			particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
			particles.emission_box_extents = Vector3(shape_size.x * area.z, shape_size.y, shape_size.z * area.y) / 2.0
	# A frente da magia é o -z do conjunto.
	particles.direction = Vector3(direction.x, direction.y, -direction.z).normalized()
	particles.spread = spread
	particles.initial_velocity_min = speed.x
	particles.initial_velocity_max = speed.y
	particles.gravity = Vector3(0.0, gravity, 0.0)
	particles.radial_accel_min = radial
	particles.radial_accel_max = radial
	particles.damping_min = damping
	particles.damping_max = damping
	particles.scale_amount_min = size_pixels.x
	particles.scale_amount_max = size_pixels.y
	if shrink:
		var curve := Curve.new()
		curve.add_point(Vector2(0.0, 1.0))
		curve.add_point(Vector2(1.0, 0.0))
		particles.scale_amount_curve = curve
	# Os riscos (esticados) apontam para onde andam.
	particles.particle_flag_align_y = stretch != 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, color_start)
	ramp.set_color(1, color_end)
	particles.color_ramp = ramp
	return particles
