shader_type canvas_item;
render_mode unshaded;
uniform float test : hint_range(0., 10., 0.01) = 0.;
uniform sampler2D noise_texture;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
const vec2 MARGIN_TEXEL_SIZE = vec2(0.5, 0.5);
void fragment() {
	vec2 margin_texel_size = (303. * TEXTURE_PIXEL_SIZE);
	vec4 noise = texture(noise_texture, (UV * (1. + MARGIN_TEXEL_SIZE * 2.) - (MARGIN_TEXEL_SIZE)), 0.);
	vec4 c = texture(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) c.rgb /= c.a;
	if(noise.r > 0.5) c.a = 0.;
	COLOR *= c;
}
