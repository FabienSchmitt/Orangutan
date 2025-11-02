extends Node2D
class_name SwarmFactory

@export var environment_manager : EnvironmentManager

var _particule_scene: PackedScene

func _ready() -> void:
	_particule_scene = preload("res://scenes/Particule.tscn")

func create_swarm(source: Cell, target: Cell, swarm_size: int) -> Swarm:
	var particules: Array[Particule] = []
	for i in range(swarm_size):
		var particule = _create_particule(source, target)
		particules.append(particule)
		get_tree().current_scene.add_child(particule)
	
	var swarm = Swarm.new(particules, target)
	swarm.environment_manager = environment_manager
	return swarm

func _create_particule(source: Cell, target: Cell) -> Particule :
	var angle = randf() * TAU
	var radius = randf() * 50.0
	var pos = source.global_position + Vector2(cos(angle), sin(angle)) * radius
	var particule = _particule_scene.instantiate()
	particule.global_position = pos
	particule.target = target
	particule.source = source
	particule.species = source.species
	return particule