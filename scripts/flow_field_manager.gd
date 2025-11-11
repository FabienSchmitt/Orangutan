class_name FlowFieldManager
extends Node2D


@export var field_size: Vector2i = Vector2i(40, 30)
@export var cell_size: float = 5
@export var obstacle_weight: int = 100
@export var debug := false

var last_flow_field : FlowField #For debug and drawing
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
			cell.cost += obstacle_weight

func check_intersect_obstacle(cell: FlowFieldCell) -> bool:
	var direct_space_state = get_world_2d().direct_space_state
	_params.transform = Transform2D(0, cell.world_position + cell.size / 2.0)
	return direct_space_state.intersect_shape(_params, 1).size() > 0.5


func compute_flow_field(destination: Vector2) -> FlowField: 
	var destination_cell =  flow_field_grid.get_cell_from_world(destination)
	last_flow_field = FlowField.new(flow_field_grid, destination_cell)
	print("destination position: ", destination, "destination_cell", destination_cell.grid_position)
	queue_redraw()
	return last_flow_field


func _draw() -> void:
	if flow_field_grid == null || !debug:
		return
		
	for i in range(field_size.x):
		draw_line(Vector2(i * cell_size, 0), Vector2(i * cell_size, field_size.y * cell_size), Color.RED, .5, true)
	for j in range(field_size.y):
		draw_line(Vector2(0, j * cell_size), Vector2(field_size.x * cell_size, j * cell_size), Color.RED, .5, true)
	 
	print("last flow field: ", last_flow_field)
	if last_flow_field == null : return	

	for cell_key: Vector2i in last_flow_field.cells:
		var cell = last_flow_field.cells[cell_key]
		draw_circle(cell.center, 0.5, Color.GREEN, false, 0.5, true) 
		draw_line(cell.center, cell.center + cell.flow * 10, Color.BLUE, 0.5, true)

		# if (cell_key.x % 10 != 0 && cell_key.y %10 != 0) : continue
		# var label = Label.new()
		# label.text = str(cell.best_cost)	
		# label.position = cell.world_position
		# add_child(label)	
		
		
		# if cell.cost < 10: continue
		# draw_circle(cell.world_position + cell.size / 2, cell.size.x / 2, Color.PURPLE, false, 0.5, true)

	
