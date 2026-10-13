shader_type spatial;
// Água, rio e lava do fundo dos abismos (10-arte-audio): a textura é uma faixa de quadros, um embaixo do outro, que
// troca com o tempo. Projetada pelo mundo, para continuar de um bloco para o outro.

uniform sampler2D frames_texture : source_color, filter_nearest, repeat_enable;
uniform float frame_count = 8.0;
uniform float frames_per_second = 4.0;
uniform vec4 tint : source_color = vec4(1.0);
uniform float glow = 0.0;
uniform float roughness_value = 0.6;

varying vec3 world_position;
varying vec3 world_normal;


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
}


void fragment() {
	vec2 across = abs(world_normal.y) > 0.5 ? world_position.xz : vec2(world_position.x + world_position.z, -world_position.y);
	float frame = mod(floor(TIME * frames_per_second), frame_count);
	vec2 uv = vec2(fract(across.x), (fract(across.y) + frame) / frame_count);
	vec3 color = texture(frames_texture, uv).rgb * tint.rgb;
	ALBEDO = color;
	EMISSION = color * glow;
	ROUGHNESS = roughness_value;
	SPECULAR = 0.3;
}
