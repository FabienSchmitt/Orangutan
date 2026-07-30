class_name HitComponent
extends Area2D

signal is_hit

var force: int = 1

func _ready() -> void:
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	force = 1
	if area.spit_force:
		force = area.spit_force
	is_hit.emit(force)

func disable() -> void:
	$CollisionShape2D.set_deferred("disabled", true)

	
