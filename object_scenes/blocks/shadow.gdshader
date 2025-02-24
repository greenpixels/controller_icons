shader_type canvas_item;

// Offset in pixels for the drop shadow.
uniform vec2 shadow_offset = vec2(0.0, 5.0);
// The color (and opacity) of the shadow.
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	// Offset the UV coordinates by the shadow offset (converted to UV space)
	vec2 offset_uv = UV + shadow_offset * TEXTURE_PIXEL_SIZE;

	// Sample the sprite’s texture at the offset.
	// We only care about its alpha (shape) for the shadow.
	float mask = texture(TEXTURE, offset_uv).a;

	// Output the shadow color modulated by the texture alpha.
	COLOR = vec4(shadow_color.rgb, shadow_color.a * mask);
}
