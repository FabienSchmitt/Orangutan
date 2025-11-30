extends CharacterBody2D

@export_category("Jump")
@export var jump_height: float = 1000
@export var jump_height_compensation_factor := 1.0524
@export var time_till_jump_apex : float = 0.35
@export var up_gravity : float = 25
@export var down_gravity: float = 50
@export var max_fall_speed : float = 300
@export var time_for_upward_cancel := 0.027
@export var apex_threshold : float = 0.97
@export var apex_hang_time : float = 0.075
@export var jump_buffer_time : float = 0.125
@export var jump_coyote_time : float = 0.1


@export_category("Horizontal movement")
@export var max_walk_speed: float = 750
@export var max_run_speed: float = 1200
@export var ground_acceleration: float = 600
@export var ground_deceleration: float = 3000
@export var air_acceleration: float = 600
@export var air_deceleration: float = 600
@export var dash_distance : float = 300
@export var dash_time: float = 0.1
@export var dash_cooldown: float = 0.5

var is_facing_right := true;
var jump_is_buffered := false
var coyote_jump_possible := false;
var was_on_floor := true;

# timers
@onready var coyote_timer: Timer  = %CoyoteTimer
@onready var buffered_jump_timer: Timer = %BufferedJumpTimer
@onready var is_dashing_timer: Timer = %IsDashingTimer
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer


# dash 
var is_dashing := false
var has_dashed := false
var is_dash_available

# Signals
signal started_falling
signal jumped
signal buffered_jump

func _ready():
	create_timer()
	started_falling.connect(on_started_falling)
	jumped.connect(on_jumped)
	buffered_jump.connect(on_buffered_jump)


func create_timer():
	coyote_timer.wait_time = jump_coyote_time
	coyote_timer.timeout.connect(func(): coyote_jump_possible = false)

	buffered_jump_timer.wait_time = jump_buffer_time
	buffered_jump_timer.timeout.connect(func(): jump_is_buffered = false)

	is_dashing_timer.wait_time = dash_time
	is_dashing_timer.timeout.connect(_dash_stop)

	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.timeout.connect(func(): is_dash_available = true)

func _dash_stop():
	velocity.x = 0
	is_dashing = false

func _physics_process(delta):

	move_horizontally(delta)
	#vertical movement
	move_vertically(delta)
	# get back the up velocity after applying horizontal movement
	emit_signals()
	update_movement_data()
	move_and_slide()    

func move_horizontally(delta: float) -> void:
	# First check for dash
	if Input.is_action_just_pressed("player_dash"):
		dash()
		
	if is_dashing:
		velocity.x = (dash_distance / dash_time) 
		if !is_facing_right:
			velocity.x *= -1
		return


	# computing horizontal movement
	var movement_direction := Input.get_action_strength("right") - Input.get_action_strength("left") 
	var movement = Vector2(movement_direction, 0) * max_walk_speed

	# if no input, we decelerate
	if movement.length() <= 1:
		velocity.x = 0
		#velocity = velocity.move_toward(Vector2(0, 0), get_deceleration() * delta)
	# otherwise we accelerate toward the x direction
	else:
		turn_check(movement.x)
		velocity = velocity.move_toward(movement, get_acceleration() * delta)

func dash():
	is_dashing = true
	is_dashing_timer.start()
	is_dash_available = false


func get_acceleration() -> float:
	return ground_acceleration if is_on_floor() else air_acceleration

func get_deceleration() -> float:
	return ground_deceleration if is_on_floor() else air_deceleration

func turn_check(x_movment: float):
	if x_movment < 0 and is_facing_right:
		turn(false)
	elif x_movment > 0 and !is_facing_right:
		turn(true)

func turn(turn_right: bool):
	is_facing_right = turn_right

func move_vertically(delta: float):
	if is_dashing:
		velocity.y = 0
		return

	if !is_on_floor():
		# NOTE : y is inverted in Godot
		var gravity = down_gravity if velocity.y >= 0 else up_gravity  
		#velocity.y = clamp(velocity.y + gravity * delta, -jump_height, max_fall_speed)
		velocity.y += gravity
	
	elif jump_is_buffered:
		jump() 
		
	if Input.is_action_just_pressed("jump") : 
		if is_on_floor() or coyote_jump_possible:
			jump()

		else: 
			buffered_jump.emit()

func jump():
	velocity.y -= jump_height
	print("on floor - jump", velocity.y)
	jumped.emit()

func emit_signals():
	if was_on_floor && !is_on_floor() && velocity.y > 0:
		started_falling.emit()
		

func update_movement_data():
	was_on_floor = is_on_floor()

func on_started_falling():
	coyote_jump_possible = true
	# restart is handled by the timer
	coyote_timer.start()
	
func on_jumped():
	# stop does not emit the timeout. makes the logic a bit fuzzy... as we may want to have some callbacks regardless of when the timer stops.
	coyote_timer.stop()
	coyote_jump_possible = false

	buffered_jump_timer.stop()
	jump_is_buffered = false

func on_buffered_jump():
	jump_is_buffered = true
	# restart is handled by the timer
	buffered_jump_timer.start()
