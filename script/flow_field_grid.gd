# A simple 2D grid data structure for flow field pathfinding.

class_name FlowFieldGrid
extends RefCounted

# Grid dimensions and storage
var width: int
var height: int
var cell_size : float
var cells := {} # Dictionary with Vector2i keys

func _init(p_grid_size: Vector2i, p_cell_size: float):
	width = p_grid_size.x
	height = p_grid_size.y
	cell_size = p_cell_size
	# Initialize grid cells with default data
	for y in range(height):
		for x in range(width):
			cells[Vector2i(x, y)] = FlowFieldCell.new(Vector2(cell_size * x, cell_size * y), cell_size)

# --- Access methods ---
func set_cost(pos: Vector2i, cost: float) -> void:
	if cells.has(pos):
		cells[pos]["cost"] = cost

func get_cost(pos: Vector2i) -> float:
	return cells.get(pos, {"cost": INF})["cost"]

func set_flow(pos: Vector2i, dir: Vector2) -> void:
	if cells.has(pos):
		cells[pos]["flow"] = dir.normalized()

func get_flow(pos: Vector2i) -> Vector2:
	return cells.get(pos, {"flow": Vector2.ZERO})["flow"]

# --- Utility methods ---
func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func get_neighbors(pos: Vector2i) -> Array:
	var offsets = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1)
	]
	var result = []
	for o in offsets:
		var neighbor = pos + o
		if in_bounds(neighbor):
			result.append(neighbor)
	return result

func reset(default_cost := INF):
	for pos in cells.keys():
		cells[pos].cost = default_cost
		cells[pos].flow = Vector2.ZERO
