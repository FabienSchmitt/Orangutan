extends Node2D
class_name SwarmFactory

var _particule_scene: PackedScene

func create_swarm(source: Cell, target: Cell, swarm_size: int) -> Swarm:
	if _particule_scene == null : 
		_particule_scene = preload("res://scenes/Particule.tscn")
	var particules: Array[Particule] = []
	for i in range(swarm_size):
		var particule = _create_particule(source, target)
		particules.append(particule)
		source.get_tree().current_scene.add_child(particule)
	
	var swarm = Swarm.new(particules, target)
	return swarm

func _create_particule(source: Cell, target: Cell) -> Particule :
	var angle = randf() * TAU
	var radius = randf() * 20
	var pos = source.global_position + Vector2(cos(angle), sin(angle)) * radius
	var particule = _particule_scene.instantiate()
	particule.global_position = pos
	particule.target = target
	particule.source = source
	particule.species = source.species
	return particule
