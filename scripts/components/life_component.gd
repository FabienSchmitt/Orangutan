class_name LifeComponent
extends Node

@export var max_health: float = 1

var current_health: float = max_health
var is_dead := false

signal died

func take_damage() -> void:
	current_health -= 1
	if current_health <= 0:
		is_dead = true
		died.emit()