extends Node
class_name Swarm

var _particules : Array[Particule]
var _target: Cell
var _source: Cell
var _center: Vector2
var environment_manager : EnvironmentManager
var species : Species

func _init(particules: Array[Particule], target: Cell) -> void:
	_particules = particules
	_target = target


func _physics_process(delta: float) -> void:
	compute_center()

	var avoidance_steering = compute_cells_avoidance()
	#print("center ", _center, "avoidance_steering  : ", avoidance_steering)
	for particule in _particules:
		#apply_flocking(particule)
		particule.move(avoidance_steering, delta)
	
	if _particules.all(func(p): return p.reached):
		clean_up()


func compute_center() -> void : 
	var sum = Vector2.ZERO
	for p in _particules: 
		sum += p.global_position

	_center = sum / _particules.size()

func compute_cells_avoidance() -> Vector2 : 
	var steering = Vector2.ZERO
	var close_cells = find_close_cells()
	#print(close_cells)
	for close_cell in close_cells:
		var to_obstacle = _center - close_cell.global_position
		var distance = to_obstacle.length()
		var avoid_force = to_obstacle.normalized() * (1.0 - distance / environment_manager.distance_threshold) * environment_manager.avoidance_strength
		steering += avoid_force
	return steering

func find_close_cells() -> Array[Cell]:
	var result := environment_manager.get_closed_cells(_center)
	result.erase(_source)
	result.erase(_target)
	return result

func clean_up():
	for p in _particules:
		p.queue_free()
	
	self.queue_free()
