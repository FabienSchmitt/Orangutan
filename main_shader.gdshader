shader_type canvas_item;

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.6;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.1;
uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv_centered = SCREEN_UV - 0.5;
    float dist = length(uv_centered) * 2.0;

    // Vignette factor
    float vignette = smoothstep(1.5 - vignette_softness,
                                1.5 - vignette_strength,
                                dist);

    // Blur radius grows with distance from center
    float radius = dist * (blur_amount / 100.0);

    // Simple radial blur (9 samples in a cross + diagonals)
    vec4 col = vec4(0.0);
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, 0.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, 0.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, -radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, -radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-radius, radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(radius, radius));
    col += texture(SCREEN_TEXTURE, SCREEN_UV);

    col /= 9.0; // average the samples

    // Apply vignette darkening
    col.rgb *= vignette;

    COLOR = col;
}