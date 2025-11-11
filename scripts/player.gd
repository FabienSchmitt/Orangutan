extends CharacterBody2D

@export() var gravity := 30.0
@export() var speed := 500.0
@export() var acceleration := 200.0
@export() var jumpSpeed := 800.0

@onready() var animated_sprite := %AnimatedSprite2D;

func _physics_process(delta: float) -> void:
	#horizontal movement
	var x = Input.get_axis("left", "right");
	velocity.x = x * speed;
	
	if ((velocity.x < 0 && !animated_sprite.flip_h) || (velocity.x > 0 && animated_sprite.flip_h)) :
		animated_sprite.flip_h = !animated_sprite.flip_h;
	
	#vertical movement
	if !is_on_floor():
		velocity.y += gravity
		animated_sprite.stop();
	elif  Input.is_action_just_pressed("jump") : 
		animated_sprite.play("jump")
		velocity.y -= jumpSpeed;
	elif abs(velocity.x) > 0.1 :
		animated_sprite.play("run");	
	else :
		animated_sprite.play("idle");
		
	move_and_slide();
