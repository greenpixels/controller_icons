shader_type canvas_item;

uniform float hue_shift : hint_range(-180, 180) = 0.0; // Hue shift in degrees

// Convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
    float cmax = max(c.r, max(c.g, c.b));
    float cmin = min(c.r, min(c.g, c.b));
    float delta = cmax - cmin;

    float h = 0.0;
    if (delta > 0.0) {
        if (cmax == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (cmax == c.g) {
            h = ((c.b - c.r) / delta) + 2.0;
        } else {
            h = ((c.r - c.g) / delta) + 4.0;
        }
        h /= 6.0;
    }

    float s = cmax == 0.0 ? 0.0 : delta / cmax;
    return vec3(h, s, cmax);
}

// Convert HSV back to RGB
vec3 hsv2rgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;

    float i = floor(h);
    float f = h - i;
    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    if (i == 0.0) return vec3(v, t, p);
    if (i == 1.0) return vec3(q, v, p);
    if (i == 2.0) return vec3(p, v, t);
    if (i == 3.0) return vec3(p, q, v);
    if (i == 4.0) return vec3(t, p, v);
    return vec3(v, p, q);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Apply hue shift
    vec3 hsv = rgb2hsv(tex_color.rgb);
    hsv.x = mod(hsv.x + hue_shift / 360.0, 1.0);
    vec3 shifted_rgb = hsv2rgb(hsv);

    COLOR = vec4(shifted_rgb, tex_color.a);
}
