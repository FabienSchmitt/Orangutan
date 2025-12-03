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

var is_facing_right := true

# timers
@onready var coyote_timer: Timer  = %CoyoteTimer
@onready var buffered_jump_timer: Timer = %BufferedJumpTimer
@onready var is_dashing_timer: Timer = %IsDashingTimer
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer

const WALKING_STATE := "walking"
const DASHING_STATE := "dashing"
const JUMPING_STATE := "jumping"
const FALLING_STATE := "falling"

var _state_machine: CallableStateMachine

func _ready():
	create_timer()
	_state_machine = CallableStateMachine.new()
	_state_machine.add_state(WALKING_STATE, walking, enter_walking, Callable())
	_state_machine.set_initial_state(WALKING_STATE)
	_state_machine.add_state(DASHING_STATE, dashing, enter_dashing, leave_dashing)
	_state_machine.add_state(JUMPING_STATE, jumping, enter_jumping, Callable())
	_state_machine.add_state(FALLING_STATE, falling, Callable(), Callable())

func create_timer():
	coyote_timer.wait_time = jump_coyote_time
	buffered_jump_timer.wait_time = jump_buffer_time
	is_dashing_timer.wait_time = dash_time
	dash_cooldown_timer.wait_time = dash_cooldown

func _physics_process(delta):
	_state_machine.update(delta)
	move_and_slide()    

func enter_walking():
	pass

func walking(delta: float):
	if !buffered_jump_timer.is_stopped():
		_state_machine.change_state(JUMPING_STATE)
		return

	move_horizontally(delta)

	if Input.is_action_just_pressed("jump") : 
		_state_machine.change_state(JUMPING_STATE)
		return

	if !is_on_floor(): # started falling
		coyote_timer.start()
		_state_machine.change_state(FALLING_STATE)

func enter_jumping():
	velocity.y -= jump_height
	print("on floor - jumping", velocity.y)

func jumping(delta: float):
	# NOTE : y is inverted in Godot
	#velocity.y = clamp(velocity.y + gravity * delta, -jump_height, max_fall_speed)
	velocity.y += up_gravity
	move_horizontally(delta)
	if velocity.y >= 0:
		_state_machine.change_state(FALLING_STATE)
	# no check on is_on_floor here to prevent weird behavior
	# if is_on_floor():
	# 	_state_machine.change_state(WALKING_STATE)

func falling(delta: float):
	if is_on_floor():
		_state_machine.change_state(WALKING_STATE)
	move_horizontally(delta)
	#velocity.y = clamp(velocity.y + gravity * delta, -jump_height, max_fall_speed)
	if Input.is_action_just_pressed("jump") : 
		if !coyote_timer.is_stopped():
			_state_machine.change_state(JUMPING_STATE)
			return
		else:
			buffered_jump_timer.start()
	velocity.y += down_gravity	


func enter_dashing():
	is_dashing_timer.start()

func dashing(delta: float):
	if is_dashing_timer.is_stopped():
		velocity.x = 0
		_state_machine.change_state(WALKING_STATE) # will move to falling if not on floor
		return

	velocity.x = (dash_distance / dash_time) 
	if !is_facing_right:
		velocity.x *= -1


func leave_dashing():
	dash_cooldown_timer.start()

func move_horizontally(delta: float) -> void:
	# First check for dash
	if Input.is_action_just_pressed("player_dash") && dash_cooldown_timer.is_stopped():
		_state_machine.change_state(DASHING_STATE)

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
