extends Node2D

@export var boids_weight: float = 2
@export var align_weight: float = 0.5
@export var cohesion_weight: float = 2
@export var avoid_weight: float = 20
@export var visibility_threshold := 75
@export var boids_size := 50
@export var starting_speed := 100
@export var max_speed := 400
@export var draw_lines := true

var _particules : Array[Particule]
var _center: Vector2
var species : Species

var _particule_scene: PackedScene

var noise: FastNoiseLite

func _ready() -> void:
	_particule_scene = preload("res://scenes/Particule.tscn")
	_create_particules()
	create_noise()


func _physics_process(delta: float) -> void:
	compute_center()
	
	var viewport_size = get_viewport_rect().size

	for p in _particules:
		var boid_force = get_boids_force(p, get_neighbors(p)).normalized() 
		p.velocity += boid_force * boids_weight
		p.velocity = p.velocity.limit_length(max_speed)
		if p.velocity.length() < starting_speed:
			p.velocity = p.velocity.normalized() * starting_speed
		p.global_position = p.global_position + p.velocity * delta

# --- Bounce on window edges ---
		var pos = p.global_position

		if pos.x < 0:
			pos.x = 0
			p.velocity.x *= -1
		elif pos.x > viewport_size.x:
			pos.x = viewport_size.x
			p.velocity.x *= -1

		if pos.y < 0:
			pos.y = 0
			p.velocity.y *= -1
		elif pos.y > viewport_size.y:
			pos.y = viewport_size.y
			p.velocity.y *= -1

		p.global_position = pos
		p.curve.add_point(p.position)
		if (p.curve.point_count > 200): p.curve.remove_point(0)

		p.rotation = p.velocity.angle() + deg_to_rad(90)
	queue_redraw()

func _draw() -> void:
	if !draw_lines : return
	for p in _particules:
		draw_polyline(p.curve.get_baked_points(), p.current_color, 0.5, true)

func _create_particules() -> void :
	for i in range(boids_size):
		var angle = randf() * TAU
		var radius = randf() * 20
		var pos = Vector2(cos(angle), sin(angle)) * radius
		var particule = _particule_scene.instantiate()
		particule.scale = Vector2(3, 3)
		particule.position = pos
		particule.velocity = Vector2(randf(), randf()).normalized() * starting_speed
		add_child(particule)
		_particules.append(particule)

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
	return avoid(p, n) * avoid_weight + stick(p, n) * cohesion_weight + align(p, n) * align_weight;

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

func align(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var avg = Vector2.ZERO
	for n in neighbors:
		avg += n.velocity
	avg /= neighbors.size()
	return (avg - current.velocity).normalized()
