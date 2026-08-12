shader_type canvas_item;
render_mode blend_mix;

uniform float green_threshold = 0.25;
uniform sampler2D yellow_notes_tex;
uniform int yellow_count;
uniform sampler2D green_notes_tex;
uniform int green_count;
uniform vec2 player_global_position_uv;
uniform float transparency_threshold = 0.1;

uniform vec4 green = vec4(0.317647, 0.788235, 0.356863, 0.392157);
uniform vec4 red = vec4(0.976471, 0.270588, 0.227451, 0.392157);
uniform vec4 yellow = vec4(1.000000, 1.000000, 0.443137, 0.392157);

float compute_distance(int count, sampler2D notes_tex, float aspect_ratio, vec2 screen_uv)
{
	float closest = 999.0;
	for (int i = 0; i < count; i++) {
		vec2 note_uv = texture(notes_tex, vec2((float(i) + 0.5) / 16.0, 0.5)).rg;
		vec2 diff = screen_uv - note_uv;
		diff.x *= aspect_ratio;
		float d = length(diff);
		closest = min(closest, d);
	}
	return closest;
}

void fragment() {	
	float screen_size_x = SCREEN_PIXEL_SIZE.x;
	float screen_size_y = SCREEN_PIXEL_SIZE.y;
	float aspect_ratio = screen_size_y / screen_size_x;
	
	// yellow distance computation
	float yellow_distance = compute_distance(yellow_count, yellow_notes_tex, aspect_ratio, SCREEN_UV);

	// green distance computation
	float green_distance = compute_distance(green_count, green_notes_tex, aspect_ratio, SCREEN_UV);

	// player distance computation
	vec2 player_diff = UV - player_global_position_uv;
	player_diff.x *= aspect_ratio;
	float player_distance = length(player_diff);

	vec4 final_color = red;
	float final_a = 0.1;
	if (yellow_distance < green_threshold) {
		final_color = yellow;
	}
	else if (green_distance < green_threshold) {
		final_color = green;
	}
	else if (player_distance < green_threshold) 	{
		final_color = green;
	}
	// transparency
	if (yellow_distance < transparency_threshold) {
		final_a = 0.0;
	}
	else if (green_distance < transparency_threshold) {
		final_a = 0.0;
	}
	else if (player_distance < transparency_threshold) {
		final_a = 0.0;
	}

	COLOR.rgb = final_color.rgb;
	COLOR.a = final_a;
}