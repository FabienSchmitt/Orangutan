extends CharacterBody2D


var facing_right := true

func _physics_process(delta: float) -> void:
	if (Input.is_action_pressed("ui_right")):
		velocity.x = 200
	elif (Input.is_action_pressed("ui_left")):
		velocity.x = -200
	else:
		velocity.x = 0


	# Change direction based on movement
	if velocity.x > 0 && not facing_right:
		change_direction(true)
	elif velocity.x < 0 && facing_right:
		change_direction(false)

	# Handle animations
	velocity.y = 0 
	if velocity.length() > 0:
		$AnimationPlayer.play("walk")
	else :
		$AnimationPlayer.play("idle")

	# Gravity
	if not is_on_floor():
		velocity.y += 80

	move_and_slide()


func change_direction(face_right: bool = true) -> void:
	facing_right = face_right
	self.scale.x *= -1