shader_type canvas_item;

uniform float blue_tint = 1.;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.b += blue_tint;
}

void vertex() {
	VERTEX += vec2(cos(TIME) * 10., 0.);
}