shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix, shadows_disabled;

// O rastro do golpe (10-arte-audio): uma meia-lua branca, grossa no meio e fina nas duas pontas, que aparece varrendo
// o arco e depois some. Fica por cima de tudo, como nos jogos 2D: Nate e as paredes não a escondem.
// UV.x vai do começo (0) ao fim do arco (1); UV.y, da beira de dentro (0) à de fora (1).

uniform vec4 color : source_color = vec4(1.0);
// Até onde a meia-lua já varreu o arco (0 a 1) e a transparência geral.
uniform float progress = 1.0;
uniform float fade = 1.0;
// Transparência do começo do arco, o mais antigo (a ponta é sólida).
uniform float tail_alpha = 1.0;
// Transparência da beira de dentro (a de fora é sólida).
uniform float inner_alpha = 1.0;

void fragment() {
	float along = UV.x;
	float across = UV.y;
	float shown = 1.0 - smoothstep(progress - 0.04, progress, along);
	float tail = mix(tail_alpha, 1.0, smoothstep(0.0, max(progress, 0.001), along));
	float edge = mix(inner_alpha, 1.0, smoothstep(0.0, 0.5, across));
	ALBEDO = color.rgb;
	ALPHA = color.a * fade * shown * tail * edge;
}
