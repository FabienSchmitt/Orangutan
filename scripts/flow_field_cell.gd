class_name FlowFieldCell
extends UniformGridCell

var flow := Vector2.ZERO
var cost := 1
var best_cost : int = 1000000

func clone(cell: FlowFieldCell) -> FlowFieldCell: 
	var new_cell = FlowFieldCell.new(cell.world_position, cell.grid_position, cell.size.x)
	new_cell.cost = cell.cost
	return new_cell

func increase_cost(amount: int) -> void:
	# TODO : we maybe want to add some clamping
	cost += amount