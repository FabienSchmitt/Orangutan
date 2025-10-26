extends Node
class_name Swarm

var _particules : Array[Particule]
var _target: Cell

func _init(particules: Array[Particule], target: Cell) -> void:
	_particules = particules
	_target = target

	
  
