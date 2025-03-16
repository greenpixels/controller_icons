shader_type canvas_item;

uniform sampler2D burn_pattern_noise;
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.;
uniform float burn_amount : hint_range(0.0, 30., 0.1) = 20.;
uniform float edge_width : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float mix_amount : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform float smoothness : hint_range(0.0, 0.99, 0.001) = 0.05;
uniform float contrast : hint_range(0.0, 10., 0.1) = 4.;
uniform vec3 edge_color : source_color = vec3(1., 0.58, 0.);
uniform float pulse_speed : hint_range(0.1, 5.0, 0.1) = 1.0;

float getBurnIntensity(vec2 uv) {
    vec3 noise = texture(burn_pattern_noise, uv).rgb;
    return (noise.r + noise.g + noise.b) / 3.0;
}

vec3 applyBurnEffect(vec3 baseColor, float intensity, float threshold, float halfEdge, float pulse) {
    vec3 modified = baseColor;
    modified += vec3(pulse + 1.0) * 0.1;
    modified = mix(edge_color, modified, mix_amount);
    modified = mix(vec3(0.5), modified, contrast);
    modified -= smoothstep(threshold, threshold - (edge_width * progress), intensity) * burn_amount;
    return modified;
}

float computeBurnAlpha(float intensity, float threshold, float smoothFactor) {
    return smoothstep(threshold, threshold - smoothFactor, intensity);
}

void fragment() {
    vec4 texColor = texture(TEXTURE, UV);
    float burnIntensity = getBurnIntensity(UV);
    
    float threshold = 1.0 - progress;
    float halfEdge = (edge_width * progress) * 0.5;
    float pulse = sin(TIME * pulse_speed);
    
    if(burnIntensity > threshold + halfEdge) {
        texColor.a = 0.0;
    }
    
    else if(burnIntensity > threshold - halfEdge) {
        texColor.rgb = applyBurnEffect(texColor.rgb, burnIntensity, threshold, halfEdge, pulse);
        texColor.a = computeBurnAlpha(burnIntensity, threshold, smoothness);
    }
    
    COLOR = texColor;
}

