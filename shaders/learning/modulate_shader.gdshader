shader_type canvas_item;

uniform float saturation : hint_range(0.0, 10.0, 0.1) = 1.;
uniform float contrast : hint_range(0., 10.0, 0.1) = 1.;

void fragment() {
	vec4 original_texture = texture(TEXTURE, UV);
	float grayscale = original_texture.r * 0.299 +  original_texture.g * 0.587 + original_texture.b * 0.114;
	
	COLOR = vec4(grayscale, grayscale, grayscale, original_texture.a);
	
	COLOR.rgb = COLOR.rgb * (1. - saturation) + original_texture.rgb * saturation;
	COLOR.rgb = mix(vec3(0.5), COLOR.rgb, contrast);

	
}