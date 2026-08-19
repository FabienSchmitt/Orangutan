class_name VelocityComponent extends Node2D

@export var target_body: CharacterBody2D
@export var max_speed: float = 350.0
@export var ground_acceleration: float = 600.0
@export var ground_deceleration: float = 3000.0
@export var air_acceleration: float = 600.0
@export var air_deceleration: float = 600.0
@export var gravity_multiplier : float = 1.5

var _dashing_initial_velocity := Vector2.ZERO 

func _ready() -> void:
	if target_body == null:
		target_body = get_parent() as CharacterBody2D
	if target_body == null:
		push_warning("VelocityComponent needs a CharacterBody2D parent or target_body.")

func configure(body: CharacterBody2D) -> void:
	target_body = body

func clamp_down_velocity(initial_jump_velocity: float):
	target_body.velocity.y = clamp(target_body.velocity.y, initial_jump_velocity, -initial_jump_velocity)	


func get_acceleration() -> float:
	return ground_acceleration if target_body.is_on_floor() else air_acceleration

func get_deceleration() -> float:
	return ground_deceleration if target_body.is_on_floor() else air_deceleration

func has_horizontal_speed() -> bool: 
	return  target_body.velocity.length() > 0.1

func apply_horizontal_velocity(delta: float, input_axis: float) -> void:
	if target_body == null:
		return

	if abs(input_axis) <= 0.001:
		target_body.velocity.x = move_toward(target_body.velocity.x, 0.0, get_deceleration() * delta)
		return

	var target_velocity: float = input_axis * max_speed
	target_body.velocity.x = move_toward(target_body.velocity.x, target_velocity, get_acceleration() * delta)

func start_jumping(initial_jump_velocity : float):
	target_body.velocity.y += initial_jump_velocity

func apply_falling_gravity(delta: float, gravity: float) -> void : 
	target_body.velocity.y += gravity * gravity_multiplier * delta

func apply_jumping_gravity(delta: float, gravity: float) -> void:
	target_body.velocity.y += (gravity *  delta / gravity_multiplier)

func stop_vertical():
	target_body.velocity.y = 0

func start_dashing():
	_dashing_initial_velocity = target_body.velocity

func apply_initial_dashing_velocity():
	target_body.velocity = _dashing_initial_velocity
	_dashing_initial_velocity = Vector2.ZERO	

func set_dashing_velocity(velocity_x : float, is_facing_right):
	target_body.velocity = Vector2(velocity_x, 0)
	if !is_facing_right:
		target_body.velocity.x *= -1
