shader_type canvas_item;
render_mode blend_mix;

// threshold
uniform float green_threshold = 0.25;
uniform float yellow_threshold = 0.25;
uniform float player_threshold = 0.25;
uniform float red_threshold = 0.25;
uniform float transparency_threshold = 0.1;

// noise stuff
uniform sampler2D noise_texture : repeat_enable;
uniform float noise_scale = 3.0;
uniform float noise_strength = 0.12;
uniform float noise_speed = 0.02;

// colors
uniform vec4 green = vec4(0.317647, 0.788235, 0.356863, 1.0);
uniform vec4 red = vec4(0.976471, 0.270588, 0.227451, 1.0);
uniform vec4 yellow = vec4(1.000000, 1.000000, 0.443137, 1.0);

// modified by code
uniform int green_count;
uniform int yellow_count;
uniform sampler2D yellow_notes_tex;
uniform sampler2D green_notes_tex;
uniform vec2 player_global_position_uv;

float get_noise(vec2 uv)
{
	vec2 noise_uv = uv * noise_scale;
	noise_uv += vec2(TIME * noise_speed, TIME * noise_speed * 0.7);

	return texture(noise_texture, noise_uv).r;
}

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
	float angle = atan(player_diff.y, player_diff.x);
	float spiral_angle = angle + player_distance * 8.0 + TIME * 0.5;
	vec2 spiral_uv = vec2(cos(spiral_angle), sin(spiral_angle)) * player_distance;
	
	float noise = get_noise(SCREEN_UV);

	float yellow_radius = yellow_threshold * (1.0 + (noise - 0.5) * noise_strength);
	float green_radius = green_threshold * (1.0 + (noise - 0.5) * noise_strength);
	float player_radius = player_threshold * (1.0 + (noise - 0.5) * noise_strength);
	float density = mix(0.5, 1.0, noise);
	
	vec4 final_color = red;
	float final_a = 0.1 * density;
	
	float yellow_fog = smoothstep(yellow_radius * 0.3, yellow_radius, yellow_distance);
	yellow_fog *= mix(0.5, 1.0, noise);
	float green_fog = smoothstep(green_radius * 0.3, green_radius, green_distance);
	green_fog *= mix(0.5, 1.0, noise);
	//float player_fog = smoothstep(player_radius * 0.3, player_radius, player_distance);
	//player_fog *= mix(0.5, 1.0, noise);
	float spiral_noise = texture(noise_texture, spiral_uv * noise_scale).r;

	float player_fog = smoothstep(player_radius * 0.3, player_radius, player_distance);
	//player_fog *= mix(0.5, 1.0, spiral_noise);
	player_fog *= spiral_noise;
	
	if (yellow_distance < yellow_radius) {
		final_color = yellow;
		final_a = yellow_fog * 0.3;
	}
	else if (green_distance < green_radius) {
		final_color = green;
		final_a = green_fog * 0.3;
	} 
	else if (player_distance < player_radius) {
		final_color = green;
		final_a = player_fog * 0.3;
	}
	else 
	{
		float closest_light_distance = min(yellow_distance, green_distance);
		float light_falloff = smoothstep(0.0, red_threshold * 3.0, closest_light_distance);
		final_a = 0.05 * density * (0.3 + light_falloff);
	}

	//COLOR.rgb = final_color.rgb;
	COLOR.a = final_a * noise;
	
	vec3 fog_color_1 = texture(noise_texture, vec2(UV.x / 2.0 + TIME /100.0, UV.y / 4.0 - TIME /100.0)).rgb;
	vec3 fog_color_2 = texture(noise_texture, vec2(UV.x / 2.0 + 0.5 + TIME / 50.0, UV.y / 4.0  + 0.5 - TIME /160.0)).rgb;
	vec3 fog_color_3 = texture(noise_texture, vec2(UV.x / 2.0 + 0.25 + TIME /25.0, UV.y / 4.0 - 0.25 + TIME /160.0)).rgb;
	vec3 fog_color = mix(fog_color_3, mix(fog_color_1, fog_color_2, 0.5), 0.7);
	//vec3 fog_color = fog_color_3;
	COLOR.rgb = fog_color * final_color.rgb;
	//COLOR.rgb *= location_fade;
}