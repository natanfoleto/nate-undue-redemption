shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never;

// Escuridão das áreas escuras (08-mapa): preta, menos num círculo de luz em volta de Nate. O círculo é medido
// no chão embaixo de cada ponto da tampa, na direção em que a câmera olha, para ficar centrado nos pés dele.

uniform vec3 center;
uniform float radius = 0.0;
uniform float edge = 1.0;
uniform float floor_height = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 ray = -normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 ground = world_position + ray * ((floor_height - world_position.y) / ray.y);
	float dist = distance(ground.xz, center.xz);
	ALBEDO = vec3(0.0);
	ALPHA = radius > 0.0 ? smoothstep(radius - edge, radius, dist) : 1.0;
}
