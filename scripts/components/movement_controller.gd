class_name MovementController extends Node2D

func get_movement() -> float: 
	return  Input.get_action_strength("right") - Input.get_action_strength("left")

func jump() -> bool: 
	return Input.is_action_just_pressed("jump")

func continue_jump() -> bool:
	return Input.is_action_pressed("jump")

func dash() -> bool:
	return Input.is_action_just_pressed("player_dash")
