class_name UniformGridCell
extends RefCounted


var world_position: Vector2
var grid_position: Vector2i
var size: Vector2
var center: Vector2 #useful for debug

func _init(p_world_pos: Vector2, p_grid_pos: Vector2i, p_size: float) -> void:
	world_position = p_world_pos
	grid_position = p_grid_pos
	size = Vector2(p_size, p_size)
	center = Vector2(p_world_pos.x + p_size / 2.0, p_world_pos.y + p_size/2.0)
    