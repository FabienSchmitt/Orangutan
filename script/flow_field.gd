class_name FlowField
extends RefCounted

var flow_field_grid: FlowFieldGrid
var destination_cell: FlowFieldCell

func _init(p_flow_field_grid: FlowFieldGrid, p_cell: FlowFieldCell) -> void:
	flow_field_grid = p_flow_field_grid
	destination_cell = flow_field_grid.cells[p_cell.grid_position]
	print("destination cell : ", destination_cell.center)
	compute_best_cost()
	compute_flow()


func compute_best_cost() -> void:
	destination_cell.cost = 0
	destination_cell.best_cost = 0

	var cells_to_check : Array[FlowFieldCell] = [destination_cell]
	var current_cell : FlowFieldCell
	var new_cost: int
	while (!cells_to_check.is_empty()):
		current_cell = cells_to_check.pop_front()
		for n in flow_field_grid.get_neighbors(current_cell.grid_position, false):
			new_cost = current_cell.best_cost + n.cost
			if (n.best_cost > new_cost):
				n.best_cost = new_cost
				cells_to_check.append(n)

func compute_flow() -> void: 
	for cell_key in flow_field_grid.cells:
		var cell = flow_field_grid.cells[cell_key]
		# if this is the destination, we don't want to add any neighbors. And flow
		# is by default Vector2.Zero.
		var best_cost = cell.best_cost 

		for n in flow_field_grid.get_neighbors(cell.grid_position, true):
			if (best_cost > n.best_cost):
				best_cost = n.best_cost
				cell.flow = n.grid_position - cell.grid_position
