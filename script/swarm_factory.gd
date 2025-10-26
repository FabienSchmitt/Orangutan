extends Node2D

var _particule_scene: PackedScene

func _ready() -> void:
	_particule_scene = preload("res://scenes/Particule.tscn")

func create_swarm(source: Cell, target: Cell, swarm_size: int) -> Swarm:
	var particules: Array[Particule] = []
	for i in range(swarm_size):
		var angle = randf() * TAU
		var radius = randf() * 50.0
		var pos = source.global_position + Vector2(cos(angle), sin(angle)) * radius
		_particule_scene = preload("res://scenes/Particule.tscn")
		var particule = _particule_scene.instantiate()
		particule.global_position = pos
		particule.target = target
		particule.source = source
		particules.append(particule)
		get_tree().current_scene.add_child(particule)

	return Swarm.new(particules, target)