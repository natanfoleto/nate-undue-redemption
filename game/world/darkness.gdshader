shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never;

// Escuridão das áreas escuras (08-mapa): preta, menos num círculo de luz em volta de Nate. O círculo é medido
// no chão embaixo de cada ponto da tampa, na direção em que a câmera olha, para ficar centrado nos pés dele.
// A forma segue os blocos escuros (a máscara, um ponto por bloco), com a borda suave e irregular, sem cara de
// retângulo preto.

uniform vec3 center;
uniform float radius = 0.0;
uniform float edge = 1.0;
uniform float floor_height = 0.0;
uniform sampler2D mask : filter_linear, repeat_disable;
// Quanto a borda ondula (0 a 1) e o tamanho das ondas, em blocos.
uniform float wobble = 0.35;
uniform float wobble_size = 1.5;

varying vec3 world_position;


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 part = fract(p);
	vec2 blend = part * part * (3.0 - 2.0 * part);
	float a = hash(cell);
	float b = hash(cell + vec2(1.0, 0.0));
	float c = hash(cell + vec2(0.0, 1.0));
	float d = hash(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, blend.x), mix(c, d, blend.x), blend.y);
}


void fragment() {
	vec3 ray = -normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 ground = world_position + ray * ((floor_height - world_position.y) / ray.y);
	float dist = distance(ground.xz, center.xz);
	float shape = texture(mask, UV).r + (value_noise(world_position.xz / wobble_size) - 0.5) * wobble;
	float dark = smoothstep(0.2, 0.8, shape);
	float light = radius > 0.0 ? smoothstep(radius - edge, radius, dist) : 1.0;
	ALBEDO = vec3(0.0);
	ALPHA = dark * light;
}
