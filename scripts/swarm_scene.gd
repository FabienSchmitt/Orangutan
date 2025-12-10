extends Node2D

@export var debug := false

func _ready() -> void:
	GameManager.create_grid()

func get_obstacle_cells() -> Array[UniformGridCell]:
	return []

func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var width = GameManager.grid.width
	var height = GameManager.grid.height
	var cell_size = GameManager.grid.cell_size
	for i in range(width):
		draw_line(Vector2(i * cell_size, 0), Vector2(i * cell_size, height * cell_size), Color.RED, .5, true, )
	for j in range(height):
		draw_line(Vector2(0, j * cell_size), Vector2(width * cell_size, j * cell_size), Color.RED, .5, true)

	