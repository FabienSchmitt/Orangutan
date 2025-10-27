extends Area2D
class_name Particule

@export var speed := 100.0
@onready var sprite : Sprite2D = $Sprite2D

#temp
var target : Cell
var source: Cell

var velocity = Vector2.ZERO
var max_speed = 100.0
var max_speed_v = Vector2.ONE * max_speed
var reached = false

func _ready() -> void:
	sprite.modulate = Color(randf(), randf(), randf())
	self.area_entered.connect(_on_area_entered)


# func _physics_process(delta: float) -> void:
# 	var direction := (target.global_position - position).normalized()
# 	position = position + direction * speed * delta
# 	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)


func move(avoidance_steering: Vector2, delta: float):
	if reached : pass
	var steering = avoidance_steering + (target.global_position - global_position).normalized() 
	position = position + steering * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area == target:
		target.damage()
		reached = true
		self.visible = false
