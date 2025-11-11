extends Area2D
class_name Particule

@export var speed := 300.0
@export var default_color := Color.BLUE
@onready var sprite : Sprite2D = $Triangle

var curve: Curve2D
#temp
var target : Cell
var source: Cell

var velocity = Vector2.ZERO
var max_speed = 200
var max_speed_v = Vector2.ONE * max_speed
var reached = false
var species: Species
var current_color : Color

func _ready() -> void:
	var base_color = default_color if species == null else species.color
	current_color = base_color + Color((randf() - 0.5) /2.0, (randf() - 0.5)/ 2.0, (randf() - 0.5)/2.0)
	sprite.modulate = current_color
	self.area_entered.connect(_on_area_entered)
	curve = Curve2D.new()


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
