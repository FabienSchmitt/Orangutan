class_name UniformGrid
extends Node2D

# Grid dimensions and storage
var width: int
var height: int
var cell_size : float
var cells := {} # Dictionary with Vector2i keys

const neighbors_offset := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

const neighbors_offset_diag := [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1),
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

func _init(p_grid_size: Vector2i, p_cell_size: float):
	width = p_grid_size.x
	height = p_grid_size.y
	cell_size = p_cell_size
	# Initialize grid cells with default data
	for y in range(height):
		for x in range(width):
			cells[Vector2i(x, y)] = UniformGridCell.new(Vector2(cell_size * x, cell_size * y), Vector2i(x, y), cell_size)

# --- Utility methods ---
func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func get_direct_neighbors(pos: Vector2i, use_diagonal: bool) -> Array[UniformGridCell]:
	var offsets = neighbors_offset if !use_diagonal else neighbors_offset_diag
	var result: Array[UniformGridCell] = []
	for o in offsets:
		var neighbor = pos + o
		if in_bounds(neighbor):
			result.append(cells[neighbor])
	return result


func get_cells_in_distance(world_pos: Vector2, distance: float) -> Array[UniformGridCell]:
	var cell = get_cell_from_world(world_pos)
	var x = cell.grid_position.x
	var y = cell.grid_position.y
	var result : Array[UniformGridCell] = []
	var iteration_number : int = ceil(distance / cell_size)
	for i in range(-iteration_number, iteration_number):
		for j in range(-iteration_number, iteration_number):
			if in_bounds(Vector2i(x + i, y + i)):
				result.append(cells[Vector2i(x + i, y + i)])

	return result


func get_cell_from_world(world_pos: Vector2) -> UniformGridCell:
	var percent_x = world_pos.x / (width * cell_size)
	var percent_y = world_pos.y / (height * cell_size)
	
	var x = clamp(floor(width * percent_x), 0, width -1)
	var y = clamp(floor(height * percent_y), 0, height -1)
	return cells[Vector2i(x, y)]

	
