shader_type canvas_item;

uniform sampler2D burn_pattern_noise;
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.;
uniform float burn_amount : hint_range(0.0, 30., 0.1) = 6.3;
uniform float edge_width : hint_range(0.0, 1.0, 0.01) = 1.;
uniform float mix_amount : hint_range(0.0, 1.0, 0.01) = 0.61;
uniform float smoothness : hint_range(0.0, 0.99, 0.001) = 0.011;
uniform float contrast : hint_range(0.0, 10., 0.1) = 6.9;
uniform vec3 edge_color : source_color = vec3(1., 0.85, 0.81);
uniform float pulse_speed : hint_range(0.1, 5.0, 0.1) = 1.4;


vec3 applyBurnEffect(vec3 baseColor, float intensity, float threshold, float halfEdge, float pulse) {
    vec3 modified = baseColor;
    modified += vec3(pulse + 1.0) * 0.05;
    modified = mix(edge_color, modified, mix_amount);
    modified = mix(vec3(0.5), modified, contrast);
    modified -= smoothstep(threshold, threshold - (edge_width * progress), intensity) * burn_amount;
    return modified;
}

void fragment() {
    vec4 texColor = texture(TEXTURE, UV);
    vec3 noiseTexture = texture(burn_pattern_noise, UV).rgb;
    float burnIntensity = (noiseTexture.r + noiseTexture.g + noiseTexture.b) / 3.;

    float threshold = 1.0 - progress;
    float halfEdge = (edge_width * progress) * 0.5;
    float pulse = sin(TIME * pulse_speed);

    if(burnIntensity > threshold + halfEdge) {
        COLOR.a = 0.0;
    }
    else if(burnIntensity > threshold - halfEdge) {
        COLOR.rgb = applyBurnEffect(texColor.rgb, burnIntensity, threshold, halfEdge, pulse);
        COLOR.a = min(texColor.a, smoothstep(threshold, threshold - smoothness, burnIntensity));
    }
}