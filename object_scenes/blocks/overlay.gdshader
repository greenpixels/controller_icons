shader_type canvas_item;

// Screen texture for the backdrop.
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
// Contrast: >1 increases contrast, <1 decreases it.
uniform float contrast : hint_range(0.0, 4.0) = 1.5;
// Opacity for the overlay effect.
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

// Multiply blend (normalized).
vec3 blend_multiply(vec3 a, vec3 b) {
    return a * b;
}

// Screen blend (normalized).
vec3 blend_screen(vec3 a, vec3 b) {
    return 1.0 - ((1.0 - a) * (1.0 - b));
}

// Hard light blending function matching Aseprite’s logic.
// Note: In Aseprite, the macro is defined as:
//   blend_hard_light(b, s) = (s < 128 ? blend_multiply(b, s*2) : blend_screen(b, s*2-1))
// When we convert to normalized values, we get:
vec3 blend_hard_light(vec3 s, vec3 b) {
    return mix(
        blend_multiply(s, b * 2.0),         // For components where b < 0.5
        blend_screen(s, b * 2.0 - 1.0),       // For components where b >= 0.5
        step(0.5, b)                        // Component-wise threshold: returns 0.0 if b < 0.5, else 1.0
    );
}


// Overlay blend mode as defined in Aseprite:
// Aseprite’s overlay is defined by swapping parameters:
//   blend_overlay(backdrop, src) = blend_hard_light(src, backdrop)
vec3 overlay_blend(vec3 backdrop, vec3 src) {
    return blend_hard_light(src, backdrop);
}

void fragment() {
    // Sample the backdrop (screen) and the sprite's texture.
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    vec4 sprite_color = texture(TEXTURE, UV);

    // Apply the sprite's modulation color.
    vec4 modulated_color = sprite_color * COLOR;

    // Apply the overlay blend using Aseprite logic:
    // Here, the screen_color is the backdrop and the modulated_color is the source.
    vec3 overlay_rgb = overlay_blend(screen_color.rgb, modulated_color.rgb);

    // Blend with the original screen color based on the opacity (like rgba_blender_normal).
    vec3 blended_rgb = mix(screen_color.rgb, overlay_rgb, opacity);

    // Adjust contrast: shift around 0.5, scale, then shift back.
    blended_rgb = (blended_rgb - 0.5) * contrast + 0.5;

    // Preserve the sprite's alpha.
    COLOR = vec4(blended_rgb, modulated_color.a);
}
