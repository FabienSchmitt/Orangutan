extends Node

var _cells : Array[Cell]
var _selected_cells : Array[Cell]

func add_cell(cell: Cell) -> void: 
	_cells.append(cell)


func add_selected_cell(cell : Cell) -> void: 
	# If the cell has already been selected, we unselect
	var exist_index = _selected_cells.find(cell) 
	if exist_index >= 0:
		_selected_cells.erase(cell)
		cell.select(false)
		return

	_selected_cells.append(cell)
	cell.select(true)

func attack_cell(cell : Cell) -> void:
	for selected_cell in _selected_cells: 
		selected_cell.attack(cell)
		selected_cell.select(false)

	_selected_cells = []


