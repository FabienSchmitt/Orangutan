class_name Player
extends CharacterBody2D

@export_category("Jump")
@export var jump_height: float = 180
@export var time_till_jump_apex : float = 0.55
@export var time_for_upward_cancel := 0.05
@export var apex_threshold : float = 0.97
@export var apex_hang_time : float = 0.075
@export var jump_buffer_time : float = 0.125
@export var jump_coyote_time : float = 0.1

@export_category("Horizontal movement")
@export var max_walk_speed: float = 350
@export var dash_distance : float = 300
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

# components
@onready var movement_controller: MovementController = %MovementController
@onready var velocity_component: VelocityComponent = %VelocityComponent
# timers
@onready var _coyote_timer: Timer  = %CoyoteTimer
@onready var _buffered_jump_timer: Timer = %BufferedJumpTimer
@onready var _jump_cancel_timer: Timer = %JumpCancelTimer
@onready var _time_till_apex_timer: Timer = %TimeTillApexTimer
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
	setup_timers()
	velocity_component.configure(self)
	create_state_machine()


func setup_timers():
	_coyote_timer.wait_time = jump_coyote_time
	_buffered_jump_timer.wait_time = jump_buffer_time
	_is_dashing_timer.wait_time = dash_time
	_dash_cooldown_timer.wait_time = dash_cooldown
	_apex_hanging_timer.wait_time = apex_hang_time
	_jump_cancel_timer.wait_time = time_for_upward_cancel
	_time_till_apex_timer.wait_time = time_till_jump_apex

func create_state_machine():
	_state_machine = CallableStateMachine.new()
	_state_machine.add_state(WALKING_STATE, walking, enter_walking, Callable())
	_state_machine.add_state(DASHING_STATE, dashing, enter_dashing, leave_dashing)
	_state_machine.add_state(JUMPING_STATE, jumping, enter_jumping, Callable())
	_state_machine.add_state(FALLING_STATE, falling, enter_falling, leave_falling)
	_state_machine.set_initial_state(WALKING_STATE)


func _physics_process(delta):
	_state_machine.update(delta)
	# regardless of state, we clamp y velocity down: 
	velocity_component.clamp_down_velocity(initial_jump_velocity)
	move_and_slide()    

func enter_walking():
	#anim.play("walk")
	pass

func walking(delta: float):

	if !is_on_floor(): # started falling
		_coyote_timer.start()
		_state_machine.change_state(FALLING_STATE)
		return 

	# if we have a buffered jump, we jump
	if ! _buffered_jump_timer.is_stopped():
		_state_machine.change_state(JUMPING_STATE)
		return

	if movement_controller.jump() && _jump_cancel_timer.is_stopped(): 
		_state_machine.change_state(JUMPING_STATE)
		return

	var has_horizontal_speed = velocity_component.has_horizontal_speed()
	if has_horizontal_speed && anim.animation != "walk":
		anim.play("walk")
	elif !has_horizontal_speed && anim.animation != "idle":
		anim.play("idle")

	move_horizontally(delta)


func enter_jumping():
	velocity_component.start_jumping(initial_jump_velocity)
	_time_till_apex_timer.start()
	print("enter jumping velocity: ", velocity.y)
	anim.play("jump")

func jumping(delta: float):
	move_horizontally(delta)

	# handling apex stuff.
	if not _apex_hanging_timer.is_stopped():
		velocity_component.stop_vertical() # we are hanging
		print ("we are hanging")
		return 
	
	# apex has been done
	if _is_apex_hanging:
		_is_apex_hanging = false
		_state_machine.change_state(FALLING_STATE)
		return

	# NOTE : y is inverted in Godot
	# NOTE : no check on is_on_floor here to prevent weird behavior : should start by going into falling state.
	if _time_till_apex_timer.is_stopped() :
		print("start hanging")
		_is_apex_hanging = true # only place we want to set it to true.
		_apex_hanging_timer.start() # start hanging timer
		return
	
	# we jump higher if we hold the jump button, otherwise we start falling
	if movement_controller.continue_jump():
		velocity_component.apply_jumping_gravity(delta, gravity)
		print("jumping gravity: ", gravity, "jumping velocity: ", velocity.y)
	else:
		_state_machine.change_state(FALLING_STATE)

func leave_jumping():
	_jump_cancel_timer.start()
	print("leave jumping velocity: ", velocity.y)	

func enter_falling():
	# TODO : change ... orobably
	anim.play("jump") 

func falling(delta: float):
	move_horizontally(delta)
	if is_on_floor():
		_state_machine.change_state(WALKING_STATE)
		return
	if movement_controller.jump() && _jump_cancel_timer.is_stopped(): 
		if !_coyote_timer.is_stopped():
			_state_machine.change_state(JUMPING_STATE)
			return
		else:
			_buffered_jump_timer.start()
	velocity_component.apply_falling_gravity(delta, gravity)
	

func leave_falling():
	print("leave falling velocity: ", velocity.y)

func enter_dashing():
	_is_dashing_timer.start()
	velocity_component.start_dashing()

func dashing(_delta: float):
	if _is_dashing_timer.is_stopped():
		_state_machine.change_state(WALKING_STATE) # will move to falling if not on floor
		return
	velocity_component.set_dashing_velocity(dash_distance / dash_time, _is_facing_right)


func leave_dashing():
	velocity_component.apply_initial_dashing_velocity()
	_dash_cooldown_timer.start()

func move_horizontally(delta: float) -> void:
	# First check for dash
	if movement_controller.dash() && _dash_cooldown_timer.is_stopped():
		_state_machine.change_state(DASHING_STATE)

	var movement_direction := movement_controller.get_movement()
	if abs(movement_direction) > 0.001:
		turn_check(movement_direction)

	velocity_component.apply_horizontal_velocity(delta, movement_direction)


func turn_check(x_movment: float):
	if x_movment < 0 and _is_facing_right:
		turn(false)
	elif x_movment > 0 and !_is_facing_right:
		turn(true)

func turn(turn_right: bool):
	_is_facing_right = turn_right
	anim.flip_h = !_is_facing_right
