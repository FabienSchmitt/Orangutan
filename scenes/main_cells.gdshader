shader_type canvas_item;

uniform vec2 target_pos;
uniform float time;

void vertex() {
	// Current instance position
    vec2 seed = COLOR.rg; // each instance’s random seed
	vec2 pos = VERTEX;

	// Add pseudo movement using the seed and time
	pos += vec2(
		sin(seed.x * 10.0 + time),
		cos(seed.y * 10.0 + time)
	) * 5.0;

	VERTEX = pos;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

