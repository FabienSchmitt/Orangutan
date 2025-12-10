extends CharacterBody2D

@export_category("Jump")
@export var jump_height: float = 150
@export var jump_height_compensation_factor: float = 1.054
@export var time_till_jump_apex : float = 0.45
@export var gravity_multiplier : float = 1.5
@export var time_for_upward_cancel := 0.027
@export var apex_threshold : float = 0.97
@export var apex_hang_time : float = 0.075
@export var jump_buffer_time : float = 0.125
@export var jump_coyote_time : float = 0.1


@export_category("Horizontal movement")
@export var max_walk_speed: float = 350
@export var max_run_speed: float = 600
@export var ground_acceleration: float = 600
@export var ground_deceleration: float = 3000
@export var air_acceleration: float = 600
@export var air_deceleration: float = 600
@export var dash_distance : float = 200
@export var dash_time: float = 0.1
@export var dash_cooldown: float = 0.5

var _is_facing_right := true
var _is_apex_hanging := false
# From the formula: v = 2h/t  -- g = -2h / t^2
# NOTE : inversed y axis already implemented
var gravity : float:
	get: return 2 * jump_height / (pow(time_till_jump_apex, 2))

var initial_jump_velocity: float:
	get: return -2 * jump_height / time_till_jump_apex

# timers
@onready var _coyote_timer: Timer  = %CoyoteTimer
@onready var _buffered_jump_timer: Timer = %BufferedJumpTimer
@onready var _is_dashing_timer: Timer = %IsDashingTimer
@onready var _dash_cooldown_timer: Timer = %DashCooldownTimer
@onready var _apex_hanging_timer: Timer = %ApexHangTimer
@onready var anim: AnimatedSprite2D = %AnimatedSprite2D

const IDLE_STATE := "idle"
const WALKING_STATE := "walking"
const DASHING_STATE := "dashing"
const JUMPING_STATE := "jumping"
const FALLING_STATE := "falling"

var _state_machine: CallableStateMachine

func _ready():
	create_timer()
	_state_machine = CallableStateMachine.new()
	_state_machine.add_state(WALKING_STATE, walking, enter_walking, Callable())
	_state_machine.add_state(DASHING_STATE, dashing, enter_dashing, leave_dashing)
	_state_machine.add_state(JUMPING_STATE, jumping, enter_jumping, Callable())
	_state_machine.add_state(FALLING_STATE, falling, Callable(), Callable())
	_state_machine.set_initial_state(WALKING_STATE)

func create_timer():
	_coyote_timer.wait_time = jump_coyote_time
	_buffered_jump_timer.wait_time = jump_buffer_time
	_is_dashing_timer.wait_time = dash_time
	_dash_cooldown_timer.wait_time = dash_cooldown
	_apex_hanging_timer.wait_time = apex_hang_time

func _physics_process(delta):
	_state_machine.update(delta)
	# regardless of state, we clamp y velocity down: 
	velocity.y = clamp(velocity.y, initial_jump_velocity, -initial_jump_velocity)
	move_and_slide()    

func enter_walking():
	anim.play("walking")

func walking(delta: float):
	if velocity.length() >= 0.1 && anim.animation != "walking":
		anim.play("walking")
	elif velocity.length() < 0.1 && anim.animation != "idle":
		anim.play("idle")

	if !_buffered_jump_timer.is_stopped():
		_state_machine.change_state(JUMPING_STATE)
		return

	move_horizontally(delta)

	if Input.is_action_just_pressed("jump") : 
		_state_machine.change_state(JUMPING_STATE)
		return

	if !is_on_floor(): # started falling
		_coyote_timer.start()
		_state_machine.change_state(FALLING_STATE)

func enter_jumping():
	velocity.y += initial_jump_velocity
	print("enter jumping velocity: ", velocity.y)
	anim.play("jump")

func jumping(delta: float):
	move_horizontally(delta)

	if not _apex_hanging_timer.is_stopped():
		velocity.y = 0 # we are hanging
		print ("we are hanging")
		return 

	velocity.y += gravity * delta
	print("jumping gravity: ", gravity, "jumping velocity: ", velocity.y)
		
	# NOTE : y is inverted in Godot
	# NOTE : no check on is_on_floor here to prevent weird behavior : should start by going into falling state.
	if velocity.y >= 0 :
		if _is_apex_hanging:
			_state_machine.change_state(FALLING_STATE)
			_is_apex_hanging = false
		else: 
			print("start hanging")
			_is_apex_hanging = true
			_apex_hanging_timer.start()
			velocity.y = 0
	
func falling(delta: float):
	if is_on_floor():
		_state_machine.change_state(WALKING_STATE)
	move_horizontally(delta)
	#velocity.y = clamp(velocity.y + gravity * delta, -jump_height, max_fall_speed)
	if Input.is_action_pressed("jump") : 
		if !_coyote_timer.is_stopped():
			_state_machine.change_state(JUMPING_STATE)
			return
		else:
			_buffered_jump_timer.start()
	velocity.y += gravity * gravity_multiplier * delta


func enter_dashing():
	_is_dashing_timer.start()

func dashing(delta: float):
	if _is_dashing_timer.is_stopped():
		velocity.x = 0
		_state_machine.change_state(WALKING_STATE) # will move to falling if not on floor
		return

	velocity.x = (dash_distance / dash_time) 
	if !_is_facing_right:
		velocity.x *= -1


func leave_dashing():
	_dash_cooldown_timer.start()

func move_horizontally(delta: float) -> void:
	# First check for dash
	if Input.is_action_just_pressed("player_dash") && _dash_cooldown_timer.is_stopped():
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
		# we want to preserve the y velocity
		var tmp_velocity = velocity.move_toward(movement, get_acceleration() * delta)
		velocity.x = tmp_velocity.x

func get_acceleration() -> float:
	return ground_acceleration if is_on_floor() else air_acceleration

func get_deceleration() -> float:
	return ground_deceleration if is_on_floor() else air_deceleration

func turn_check(x_movment: float):
	if x_movment < 0 and _is_facing_right:
		turn(false)
	elif x_movment > 0 and !_is_facing_right:
		turn(true)

func turn(turn_right: bool):
	_is_facing_right = turn_right
	anim.flip_h = !_is_facing_right
