extends CharacterBody2D

@export var speed: float = 300

func _physics_process(delta):
    var direction = Vector2.ZERO
    direction += Vector2.LEFT * Input.get_action_strength("left") + Vector2.RIGHT * Input.get_action_strength("right") 
    direction += Vector2.UP * Input.get_action_strength("up") + Vector2.DOWN * Input.get_action_strength("down")
    velocity = direction * speed 
    move_and_slide()    