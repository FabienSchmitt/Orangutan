extends Node2D
class_name  EnvironmentManager

@export var distance_threshold := 1000000.0
@export var avoidance_strength := 1.5

var cells: Array[Cell]

func _ready() -> void:
	cells = []
	var existing_cells = get_tree().get_nodes_in_group("cells")
	cells.append_array(existing_cells)

func get_closed_cells(test_position: Vector2) -> Array[Cell]:
	var result : Array[Cell] = []
	print(cells)
	for cell in cells:
		if _is_close(cell, test_position):
			result.append(cell)
	return result

func _is_close(cell: Cell, test_position: Vector2) -> bool: 
	#print (cell.global_position, test_position)
	var distance = (cell.global_position - test_position).length()
	return distance < distance_threshold
