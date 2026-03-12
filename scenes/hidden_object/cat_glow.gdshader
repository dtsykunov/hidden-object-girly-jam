shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float glow_size : hint_range(1.0, 8.0) = 4.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	if (glow_strength < 0.001) {
		COLOR = col;
	} else {
		vec2 ps = TEXTURE_PIXEL_SIZE * glow_size;
		float outline = 0.0;
		outline = max(outline, texture(TEXTURE, UV + vec2( ps.x,  0.0)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2(-ps.x,  0.0)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2( 0.0,  ps.y)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2( 0.0, -ps.y)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2( ps.x,  ps.y)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2(-ps.x,  ps.y)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2( ps.x, -ps.y)).a);
		outline = max(outline, texture(TEXTURE, UV + vec2(-ps.x, -ps.y)).a);

		if (col.a < 0.1) {
			COLOR = vec4(glow_color.rgb, outline * glow_strength);
		} else {
			COLOR = mix(col, vec4(col.rgb * glow_color.rgb * 1.5, col.a), glow_strength * 0.3);
		}
	}
}
