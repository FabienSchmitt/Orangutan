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
var species: Species

func _ready() -> void:
	var modulo = (randf() - 0.5) 
	sprite.modulate = species.color + Color((randf() - 0.5) /2.0, (randf() - 0.5)/ 2.0, (randf() - 0.5)/2.0)
	self.area_entered.connect(_on_area_entered)


# func _physics_process(delta: float) -> void:
# 	var direction := (target.global_position - position).normalized()
# 	position = position + direction * speed * delta
# 	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)


func move(avoidance_steering: Vector2, delta: float):
	if reached : return
	var steering = avoidance_steering.normalized() + (target.global_position - global_position).normalized() *1.5
	position = position + steering * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area != target: return

	var damage = 1
	if target.species == species:
		damage = -1
	target.damage(damage, species)
	reached = true
	self.visible = false
