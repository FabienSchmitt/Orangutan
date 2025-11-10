extends Node
class_name Swarm

var _particules : Array[Particule]
var _target: Cell
var _source: Cell
var _center: Vector2
var environment_manager : EnvironmentManager
var species : Species

var seek_weight: float = 10
var align_weight: float = 1
var cohesion_weight: float = 1
var avoid_weight: float = 2
var visibility_threshold := 75

var flow_field: FlowField
var noise: FastNoiseLite


func _init(particules: Array[Particule], target: Cell) -> void:
	_particules = particules
	_target = target
	flow_field = target.flow_field
	print("target flow field : ", flow_field)
	create_noise()


func _physics_process(delta: float) -> void:
	compute_center()
	
	#print("particules : ", flow_field.destination_cell.world_position, flow_field.destination_cell.grid_position)
	for p in _particules:
		var cell_below = flow_field.get_cell_from_world(p.global_position)
		var direction = cell_below.flow.normalized() 

		# adding some noise
		var angle = randf() * TAU
		direction +=  Vector2(cos(angle), sin(angle)) 

		# var flow_angle = noise.get_noise_2d(p.position.x * 0.01, p.position.y * 0.01) * TAU
		# var flow_dir = Vector2(cos(flow_angle), sin(flow_angle))
		# var jitter_strength = 0.5 # radians (about 11 degrees)
		# var random_angle = randf_range(-jitter_strength, jitter_strength)
		# direction = direction.rotated(random_angle)
		
		var boid_force = get_boids_force(p, get_neighbors(p)).normalized() 
		p.velocity += boid_force * 0.5 + direction * seek_weight
		p.velocity = p.velocity.limit_length(p.speed)
		p.global_position = p.global_position + p.velocity * delta
	
	if _particules.all(func(p): return p.reached):
		clean_up()


func create_noise() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()  # Optional random seed
	noise.frequency = 0.02

func compute_center() -> void : 
	var sum = Vector2.ZERO
	for p in _particules: 
		sum += p.position

	_center = sum / _particules.size()

func clean_up():
	for p in _particules:
		p.queue_free()
	
	self.queue_free()


# BOIDS STUFF: BAD PERF
func get_boids_force(p: Particule, n: Array[Particule]) -> Vector2:
	if n == []:
		return Vector2.ZERO
	return avoid(p, n) * avoid_weight + stick(p, n) * cohesion_weight + align() * align_weight;

func get_neighbors(current: Particule) -> Array[Particule]:
	return _particules.filter(func(other) : return other != current && \
		other.position.distance_to(current.position) < visibility_threshold)


func avoid(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var result = Vector2.ZERO

	for other in neighbors:
		var distance_to = current.position.distance_to(other.position)
		if distance_to > 25 : continue
		result += (current.position - other.position).normalized() * (1 - distance_to / visibility_threshold)
	return result

func stick(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var center = neighbors.reduce(func(c, p): return p.position + c, Vector2.ZERO) / neighbors.size()
	return (center - current.position).normalized()

func align() -> Vector2:
	return Vector2.ZERO
