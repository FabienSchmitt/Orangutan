class_name Connection
extends RefCounted

var behavior : GameManager.Behaviors
var source: Cell
var target: Cell
var distance: float = 0

func _init(p_behavior: GameManager.Behaviors, p_source: Cell, p_target: Cell) -> void:
	behavior = p_behavior
	source = p_source
	target = p_target
	distance = p_source.global_position.distance_to(target.global_position)


