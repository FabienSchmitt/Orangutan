extends Node2D

const MAX_YELLOW := 16
const MAX_GREEN := 16

@export var fog_color_rect: ColorRect
@export var green_fog_threshhold: float = 0.25
@export var fog_active: bool = true



var _player : Node2D
var _yellow_fog_tex := ImageTexture.new()
var _green_fog_tex := ImageTexture.new()

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("Player")

	# compute yellow stuff here as it does not move. 
	var yellow_fog_positions : Array[Vector2] = []
	for node in get_tree().get_nodes_in_group("YellowFog"):
		yellow_fog_positions.append(compute_uv_coordinates(node))
	update_yellow_fog_elements(yellow_fog_positions)


func _process(delta: float) -> void:
	if !fog_active: return

	# get player and set its position
	fog_color_rect.material.set_shader_parameter("player_global_position_uv", compute_uv_coordinates(_player))
	print("fog material: ", fog_color_rect.material)

	var green_fog_positions : Array[Vector2] = []
	for node in get_tree().get_nodes_in_group("GreenFog"):
		green_fog_positions.append(compute_uv_coordinates(node))
	update_green_fog_elements(green_fog_positions)



func update_green_fog_elements(positions: Array[Vector2]) -> void:
	var img := Image.create(MAX_GREEN, 1, false, Image.FORMAT_RGF)
	for i in range(MAX_GREEN):
		if i < positions.size():
			img.set_pixel(i, 0, Color(positions[i].x, positions[i].y, 0.0))
		else:
			img.set_pixel(i, 0, Color(-1.0, -1.0, 0.0))
	_green_fog_tex.set_image(img)
	fog_color_rect.material.set_shader_parameter("green_notes_tex", _green_fog_tex)
	fog_color_rect.material.set_shader_parameter("green_count", positions.size())

func update_yellow_fog_elements(positions: Array[Vector2]) -> void:
	var img := Image.create(MAX_YELLOW, 1, false, Image.FORMAT_RGF)
	for i in range(MAX_YELLOW):
		if i < positions.size():
			img.set_pixel(i, 0, Color(positions[i].x, positions[i].y, 0.0))
		else:
			img.set_pixel(i, 0, Color(-1.0, -1.0, 0.0))
	_yellow_fog_tex.set_image(img)
	fog_color_rect.material.set_shader_parameter("yellow_notes_tex", _yellow_fog_tex)
	fog_color_rect.material.set_shader_parameter("yellow_count", positions.size())

func compute_uv_coordinates(node: Node) -> Vector2:
	var screen_pos = get_viewport().get_canvas_transform() * node.global_position
	return screen_pos / get_viewport().get_visible_rect().size
