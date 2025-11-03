class_name FlowFieldCell
extends RefCounted

var world_position: Vector2
var flow : Vector2i = Vector2i.ZERO
var cost: float = 1.0
var area: Area2D
var size: Vector2

func _init(p_world_pos: Vector2, p_size: float) -> void:
	world_position = p_world_pos
	size = Vector2(p_size, p_size)
