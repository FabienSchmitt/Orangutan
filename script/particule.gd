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

func _ready() -> void:
	sprite.modulate = Color(randf(), randf(), randf())
	self.area_entered.connect(_on_area_entered)


# func _physics_process(delta: float) -> void:
# 	var direction := (target.global_position - position).normalized()
# 	position = position + direction * speed * delta
# 	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)



func _physics_process(delta):
	var steering = Vector2.ZERO
	var overlapped := false

	# Avoid non-target large areas
	for area in get_overlapping_areas():
		if area.is_in_group("cells") and area != target and area != source:
			steering += (global_position - area.global_position).normalized() * 0.6
			

	# Seek target area
	steering += (target.global_position - global_position).normalized()

	# Boids behavior (alignment, cohesion, separation)
	# ... add your boids steering calculations here ...

	#global_position += steering.normalized() * max_speed * delta

	velocity += steering * delta
	#elocity = velocity.clamped(max_speed)
	global_position += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area == target:
		target.damage()
		self.queue_free()
