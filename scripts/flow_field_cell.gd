class_name FlowFieldCell
extends RefCounted

var world_position: Vector2
var grid_position: Vector2i
var flow := Vector2.ZERO
var cost := 1
var best_cost : int = 1000000
var size: Vector2
var center: Vector2 #useful for debug

func _init(p_world_pos: Vector2, p_grid_pos: Vector2i, p_size: float) -> void:
	world_position = p_world_pos
	grid_position = p_grid_pos
	size = Vector2(p_size, p_size)
	center = Vector2(p_world_pos.x + p_size / 2.0, p_world_pos.y + p_size/2.0)

func clone(cell: FlowFieldCell) -> FlowFieldCell: 
	var new_cell = FlowFieldCell.new(cell.world_position, cell.grid_position, cell.size.x)
	new_cell.cost = cell.cost
	return new_cell

func increase_cost(amount: int) -> void:
	# TODO : we maybe want to add some clamping
	cost += amount