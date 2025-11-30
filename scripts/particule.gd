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

var active_ray := 0
var obstace_in_front = false

@onready var visual_rays : Array[RayCast2D]= [%VisualRay1, %VisualRay2, %VisualRay3, %VisualRay4, %VisualRay5, %VisualRay6, %VisualRay7, %VisualRay8, %VisualRay9, %VisualRay10, %VisualRay11]
@onready var predator_rays : Array[RayCast2D] = [%PredatorRay1, %PredatorRay2, %PredatorRay3, %PredatorRay4, %PredatorRay5, %PredatorRay6, %PredatorRay7, %PredatorRay8, %PredatorRay9, %PredatorRay10, %PredatorRay11, %PredatorRay12, %PredatorRay13]

func _ready() -> void:
	var base_color = default_color if species == null else species.color
	current_color = base_color + Color((randf() - 0.5) /5.0, (randf() - 0.5)/ 5.0, (randf() - 0.5)/5.0)
	sprite.modulate = current_color
	if species.predators != null:
		self.area_entered.connect(_on_area_entered)
	curve = Curve2D.new()

func update_velocity_to_avoid_obstacles() -> void: 
	# we start with the forward direction first and we return the new velocity based on obstacle avoidance.
	for ray in visual_rays:
		if !ray.is_colliding(): 
			velocity = velocity.rotated(ray.transform.get_rotation())
			return

	# all ray collides, we go the opposite way
	velocity = -velocity

func get_hunting_direction() -> Vector2:
	for ray in predator_rays:
		if ray.is_colliding():
			var collider := ray.get_collider() as Particule
			if collider != null && species.preys.find(collider.species) >= 0:
				return collider.global_position - global_position
	return Vector2.ZERO

func get_fleeing_direction() -> Vector2:
	for ray in predator_rays:
		if ray.is_colliding():
			var collider := ray.get_collider() as Particule
			if collider != null && species.predators.find(collider.species) >= 0:
				return global_position - collider.global_position
	return Vector2.ZERO

func _on_area_entered(a: Area2D) -> void:
	if not (a is Particule) : return
	var area :Particule = a 
	if species.predators.has(area.species):
		print("I am dead")
		queue_free()


	#cell usage
	# if area != target: return

	# var damage = 1
	# if target.species == species:
	# 	damage = -1
	# target.damage(damage, species)
	# reached = true
	# self.visible = false
