extends Node2D

@export var draw_lines := true
@export var species: Species
@export var queen: Node2D

var _particules : Array[Particule]
var _particule_scene: PackedScene
var _noise: FastNoiseLite
var _active_cells: Dictionary
var _active_neighbors: Dictionary

func _ready() -> void:
	_particule_scene = preload("res://scenes/Particule.tscn")
	_create_particules()
	create_noise()
	for predator in species.predators:
		if predator.preys.has(species) : continue
		predator.preys.append(species)


func _physics_process(delta: float) -> void:
	compute_neighboring_cells()

	for p in _particules:
		compute_velocity(p)		
		p.update_velocity_to_avoid_obstacles()
		p.global_position = p.global_position + p.velocity * delta

		# Go to the other side of the screen
		#p.global_position = move_to_the_other_side(p.global_position)
		p.curve.add_point(p.position)
		if (p.curve.point_count > 200): p.curve.remove_point(0)

		p.rotation = p.velocity.angle() + deg_to_rad(90)
	queue_redraw()

func compute_velocity(p: Particule) -> void:
	var boid_force = get_boids_force(p, get_neighbors(p)).normalized() 
	p.velocity += boid_force * species.boids_weight
	if species.has_queen:
		var queen_force = get_queen_force(p)
		p.velocity += queen_force * species.queen_weight
	# can be optimize if we know if there are any preys nearby 
	if species.preys != []:
		var hunting_force = get_hunting_force(p)
		p.velocity += hunting_force * species.chasing_weight

	if species.predators != []:
		var fleeing_force = get_fleeing_force(p)
		p.velocity += fleeing_force * species.fleeing_weight

	p.velocity = p.velocity.limit_length(species.max_speed)
	if p.velocity.length() < species.starting_speed:
		p.velocity = p.velocity.normalized() * species.starting_speed

func _draw() -> void:
	if !draw_lines : return
	for p in _particules:
		draw_polyline(p.curve.get_baked_points(), p.current_color, 0.5, true)

func _create_particules() -> void :
	print("color : ", species.name)
	for i in range(species.boids_size):
		var angle = randf() * TAU
		var radius = randf() * 300
		var pos = Vector2(cos(angle), sin(angle)) * radius
		var particule = _particule_scene.instantiate()
		particule.species = species
		particule.scale = Vector2(3, 3)
		particule.position = pos
		particule.velocity = Vector2(randf() -0.5, randf() - 0.5).normalized() * species.starting_speed
		add_child(particule)
		_particules.append(particule)
		particule.tree_exiting.connect(remove_dead_particule.bind(particule))

func create_noise() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.seed = randi()  # Optional random seed
	_noise.frequency = 0.02

func remove_dead_particule(p: Particule) -> void:
	_particules.erase(p)

func move_to_the_other_side(pos: Vector2) -> Vector2:
	var viewport_size = get_viewport_rect().size

	if pos.x < 0:
		pos.x += viewport_size.x
	elif pos.x > viewport_size.x:
		pos.x -= viewport_size.x

	if pos.y < 0:
		pos.y += viewport_size.y
	elif pos.y > viewport_size.y:
		pos.y -= viewport_size.y
	
	return pos


func clean_up():
	for p in _particules:
		p.queue_free()
	
	self.queue_free()

func get_queen_force(p: Particule):
	return (queen.global_position - p.global_position).normalized()

func get_hunting_force(p: Particule):
	return p.get_hunting_direction().normalized()

func get_fleeing_force(p: Particule):
	return p.get_fleeing_direction().normalized()

func get_boids_force(p: Particule, n: Array[Particule]) -> Vector2:
	if n == []:
		return Vector2.ZERO
	return avoid(p, n) * species.avoid_weight + stick(p, n) * species.cohesion_weight + align(p, n) * species.align_weight;

func compute_neighboring_cells() -> void:
	# get all the cells containing boid
	_active_cells = {}
	_active_neighbors = {}
	for p in _particules:
		var c = GameManager.grid.get_cell_from_world(p.global_position)
		if _active_cells.has(c): 
			_active_cells[c].append(p)
			continue
		_active_cells[c] = [p]
		_active_neighbors[c] = GameManager.grid.get_cells_in_distance(c.world_position, species.visibility_threshold)


func get_neighbors(current: Particule) -> Array[Particule]:
	# first get the grid cells to check
	var cell = GameManager.grid.get_cell_from_world(current.global_position)
	# based on eyesight, we check what neighbors cells to check:
	var cells_to_check = _active_neighbors[cell]
	var possible_boids : Array[Particule] = []
	for c in cells_to_check:
		if !_active_cells.has(c): continue
		possible_boids.append_array(_active_cells[c])
	
	return possible_boids.filter(func(other) : return other != current && \

		other.position.distance_to(current.position) < species.visibility_threshold)



func avoid(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var result = Vector2.ZERO

	for other in neighbors:
		var distance_to = current.position.distance_to(other.position)
		if distance_to > 25 : continue
		result += (current.position - other.position).normalized() * (1 - distance_to / species.visibility_threshold)
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
