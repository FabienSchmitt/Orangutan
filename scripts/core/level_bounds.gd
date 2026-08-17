@tool
@icon("res://general/icons/level_bounds.svg")
class_name  LevelBounds extends Node2D

@export_range(648, 2_000_000, 32, "suffix:px") var height : int : set = _set_height
@export_range(1152, 4_000_000, 32, "suffix:px") var width : int : set = _set_width

var _camera: Camera2D

func _ready() -> void:

	# we make sure it's always on top
	z_index = 256
	if Engine.is_editor_hint(): 
		return
	

	while not _camera:
		# we don't want to block the entire process if no camera is found, so we make sure it's async. 
		await get_tree().process_frame
		_camera = get_viewport().get_camera_2d()

	_camera.limit_left = int (global_position.x)
	_camera.limit_top = int(global_position.y)
	_camera.limit_right = int(global_position.x) + width
	_camera.limit_bottom = int(global_position.y) + height

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	var rect := Rect2(Vector2.ZERO, Vector2(width, height))
	draw_rect(rect, Color.TURQUOISE, false, 5)

func _set_height(h: int) -> void:
	height = h
	queue_redraw()

func _set_width(w: int) -> void:
	width = w
	queue_redraw()
