extends Area2D
class_name Particule

@export var speed := 100.0
@onready var sprite : Sprite2D = $Sprite2D

#temp
var target : Cell

func _ready() -> void:
	sprite.modulate = Color(randf(), randf(), randf())
	self.area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	var direction := (target.global_position - position).normalized()
	position = position + direction * speed * delta
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func _on_area_entered(area: Area2D) -> void:
	if area == target:
		target.damage()
		self.queue_free()
