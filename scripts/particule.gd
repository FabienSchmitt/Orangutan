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
@onready var rays : Array[RayCast2D]= [$Ray1, $Ray2, $Ray3, $Ray4, $Ray5, $Ray6, $Ray7, $Ray8, $Ray9, $Ray10, $Ray11]

func _ready() -> void:
	var base_color = default_color if species == null else species.color
	current_color = base_color + Color((randf() - 0.5) /2.0, (randf() - 0.5)/ 2.0, (randf() - 0.5)/2.0)
	sprite.modulate = current_color
	self.area_entered.connect(_on_area_entered)
	curve = Curve2D.new()
	

func update_velocity_to_avoid_obstacles() -> void: 
	# we start with the forward direction first and we return the new velocity based on obstacle avoidance.
	for ray in rays:
		if ray.is_colliding(): 
			print("collision with ray # ", rays.find(ray), " - ", ray.target_position, " velocity is ", velocity)
		else : 			
			velocity = velocity.rotated(ray.transform.get_rotation())
			if rays.find(ray) != 0 : 
				print("collision with ray # ", rays.find(ray), " - ", ray.target_position, " new velocity is ", velocity)

			return


	# we have checked all the enabled rays. 




func _on_area_entered(area: Area2D) -> void:
	if area != target: return

	var damage = 1
	if target.species == species:
		damage = -1
	target.damage(damage, species)
	reached = true
	self.visible = false
