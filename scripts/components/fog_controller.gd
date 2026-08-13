extends Node2D

const MAX_YELLOW := 16
const MAX_GREEN := 16

@export var fog_color_rect: ColorRect
@export var green_fog_threshold: float = 0.25
@export var yellow_fog_threshold: float = 0.35
@export var fog_active: bool = true

var _player : Node2D
var _player_gauge : float = 100.0
var _yellow_fog_tex := ImageTexture.new()
var _green_fog_tex := ImageTexture.new()
var _green_fog_positions : Array[Vector2] = []
var _yellow_fog_positions : Array[Vector2] = []

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")

	# compute yellow stuff here as it does not move. 
	update_yellow_fog()
	set_shader_treshold()
	EventBus.lit_light.connect(on_lit_light)
	EventBus.unlit_light.connect(on_unlit_light)

func set_shader_treshold():
	fog_color_rect.material.set_shader_parameter("green_threshold", green_fog_threshold)
	fog_color_rect.material.set_shader_parameter("yellow_threshold", yellow_fog_threshold)

func _process(delta: float) -> void:
	if !fog_active: return

	_green_fog_positions = []
	for node in get_tree().get_nodes_in_group("GreenFog"):
		_green_fog_positions.append(node.global_position)
	update_green_fog_elements(_green_fog_positions)

	# first update green fog, then player.
	update_player_fog(delta)


func compute_uv_coordinates(node_global_position: Vector2) -> Vector2:
	var screen_pos = get_viewport().get_canvas_transform() * node_global_position
	return screen_pos / get_viewport().get_visible_rect().size

# GREEN FOG
func update_green_fog_elements(global_positions: Array[Vector2]) -> void:
	var uv_positions = global_positions.map(compute_uv_coordinates)
	var img := Image.create(MAX_GREEN, 1, false, Image.FORMAT_RGF)
	for i in range(MAX_GREEN):
		if i < uv_positions.size():
			img.set_pixel(i, 0, Color(uv_positions[i].x, uv_positions[i].y, 0.0))
		else:
			img.set_pixel(i, 0, Color(-1.0, -1.0, 0.0))
	_green_fog_tex.set_image(img)
	fog_color_rect.material.set_shader_parameter("green_notes_tex", _green_fog_tex)
	fog_color_rect.material.set_shader_parameter("green_count", uv_positions.size())

# PLAYER FOG
func update_player_fog(delta: float) -> void:
	if _player == null : return

	var touching_lights_number = get_lights_in_range()
	recharge_gauge(touching_lights_number, delta)
	
	# player shader properties
	fog_color_rect.material.set_shader_parameter("player_global_position_uv", compute_uv_coordinates(_player.global_position))
	fog_color_rect.material.set_shader_parameter("player_threshold", _player_gauge / 100 * 0.25)


func get_lights_in_range() -> int :
	var result := 0

	# in the shader, the size of the circle is normalized to the y size.
	# HACK: this is a simplified version, it does not take into account the camera zoom
	var _world_yellow_threshold = get_viewport().get_visible_rect().size.y  * yellow_fog_threshold
	var _world_green_threshold = get_viewport().get_visible_rect().size.y  * green_fog_threshold
	result += _yellow_fog_positions.filter(func(x: Vector2): return x.distance_to(_player.global_position) < _world_yellow_threshold).size()
	result += _green_fog_positions.filter(func(x: Vector2): return x.distance_to(_player.global_position) < _world_green_threshold).size()

	return result

func recharge_gauge(touching_lights_number: int, delta: float):
	# playing with number on feeling...
	var multiplier := -3 if touching_lights_number == 0 else touching_lights_number * 5
	_player_gauge += multiplier * delta * 5
	# percentage
	_player_gauge = clamp(_player_gauge, 0, 100)

# YELLOW FOG
func on_lit_light() -> void:
	update_yellow_fog()

func on_unlit_light() -> void:
	update_yellow_fog()

func update_yellow_fog() -> void:
	_yellow_fog_positions = []
	for node in get_tree().get_nodes_in_group("YellowFog"):
		_yellow_fog_positions.append(node.global_position)
	update_yellow_fog_elements(_yellow_fog_positions)

func update_yellow_fog_elements(node_global_positions: Array[Vector2]) -> void:
	if node_global_positions.size() == 0: 
		return
	var uv_positions = node_global_positions.map(compute_uv_coordinates)
	var img := Image.create(MAX_YELLOW, 1, false, Image.FORMAT_RGF)
	for i in range(MAX_YELLOW):
		if i < uv_positions.size():
			img.set_pixel(i, 0, Color(uv_positions[i].x, uv_positions[i].y, 0.0))
		else:
			img.set_pixel(i, 0, Color(-1.0, -1.0, 0.0))
	_yellow_fog_tex.set_image(img)
	fog_color_rect.material.set_shader_parameter("yellow_notes_tex", _yellow_fog_tex)
	fog_color_rect.material.set_shader_parameter("yellow_count", uv_positions.size())
