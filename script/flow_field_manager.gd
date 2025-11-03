class_name FlowFieldManager
extends Node2D


@export var field_size: Vector2i = Vector2i(40, 30)
@export var cell_size: float = 5

var flow_field_grid: FlowFieldGrid
var _params: PhysicsShapeQueryParameters2D

func _ready() -> void:
	flow_field_grid = FlowFieldGrid.new(field_size, cell_size)
	_params = PhysicsShapeQueryParameters2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(cell_size, cell_size)
	_params.shape = shape
	_params.collide_with_areas = true
	_params.collide_with_bodies = false
	_params.collision_mask = 1

	add_obstacles()


func add_obstacles() -> void:
	for cell_key in flow_field_grid.cells:
		var cell = flow_field_grid.cells[cell_key]
		if check_intersect_obstacle(cell): 
			flow_field_grid.set_cost(cell_key, cell.cost + 100)

func check_intersect_obstacle(cell: FlowFieldCell) -> bool:
	var direct_space_state = get_world_2d().direct_space_state
	_params.transform = Transform2D(0, cell.world_position + cell.size / 2.0)
	return direct_space_state.intersect_shape(_params, 1).size() > 0

func _draw() -> void:
	if flow_field_grid == null:
		return
		
	for i in range(field_size.x):
		draw_line(Vector2(i * cell_size, 0), Vector2(i * cell_size, field_size.y * cell_size), Color.RED, .5, true)
	for j in range(field_size.y):
		draw_line(Vector2(0, j * cell_size), Vector2(field_size.x * cell_size, j * cell_size), Color.RED, .5, true)

	for cell_key in flow_field_grid.cells:
		var cell = flow_field_grid.cells[cell_key]
		if cell.cost < 100: continue
		draw_circle(cell.world_position + cell.size / 2, cell.size.x / 2, Color.BLUE, false, 0.5, true)

	
