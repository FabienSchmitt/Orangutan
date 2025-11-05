extends Node
class_name Swarm

var _particules : Array[Particule]
var _target: Cell
var _source: Cell
var _center: Vector2
var environment_manager : EnvironmentManager
var species : Species

var seek_weight: float = 1
var align_weight: float = 1
var cohesion_weight: float = 5
var avoid_weight: float = 10
var visibility_threshold := 10

var flow_field: FlowField


func _init(particules: Array[Particule], target: Cell) -> void:
	_particules = particules
	_target = target
	flow_field = target.flow_field
	print("target flow field : ", flow_field)


func _physics_process(delta: float) -> void:
	compute_center()

	for p in _particules:
		var cell_below = flow_field.flow_field_grid.get_cell_from_world(p.global_position)
		var direction = cell_below.flow.normalized()

		direction += get_boids_noise(p);
		
		p.position = p.position + direction * p.speed * delta
	
	if _particules.all(func(p): return p.reached):
		clean_up()

func get_boids_noise(p: Particule) -> Vector2:
	return avoid(p) * avoid_weight + stick(p) * cohesion_weight + align() * align_weight;

func avoid(current: Particule) -> Vector2:
	var result = Vector2.ZERO
	for other in _particules:
		var distance_to = current.global_position.distance_to(other.global_position)
		if  distance_to < visibility_threshold:
			result += (current.global_position - other.global_position).normalized() * (1 - distance_to / visibility_threshold)
	return result

func stick(p: Particule) -> Vector2:
	return (_center - p.global_position).normalized()

func align() -> Vector2:
	return Vector2.ZERO

	



func compute_center() -> void : 
	var sum = Vector2.ZERO
	for p in _particules: 
		sum += p.global_position

	_center = sum / _particules.size()

func clean_up():
	for p in _particules:
		p.queue_free()
	
	self.queue_free()
