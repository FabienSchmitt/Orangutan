extends Node

var grid: UniformGrid

## Species
func create_grid() -> void:
	#default value, should come as a parameter I guess...
	grid = UniformGrid.new(Vector2i(23, 13), 50)
