// Marca de aviso no chão (10-arte-audio): vermelho-alaranjada, com listras diagonais que vão enchendo até o golpe.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.35, 0.12, 1.0);
// Quanto da preparação já passou, de 0 a 1: as listras enchem de quem golpeia até a borda de fora.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// Largura de cada listra, em blocos.
uniform float stripe_width = 0.25;
// Opacidade da área inteira, visível desde o começo, e das listras.
uniform float area_alpha = 0.25;
uniform float stripe_alpha = 0.5;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float stripe = step(0.5, fract((world_position.x + world_position.z) / (2.0 * stripe_width)));
	float filled = step(UV.x, progress);
	ALBEDO = color.rgb;
	ALPHA = area_alpha + filled * stripe * stripe_alpha;
}
