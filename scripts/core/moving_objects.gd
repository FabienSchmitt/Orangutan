class_name MovingObject 
extends RigidBody2D

@export var interactable: Interactable

var _grabbed_by: Node2D

func _ready() -> void:
	interactable.interacted.connect(try_grab)

func _physics_process(_delta: float) -> void:
	if _grabbed_by:
		_drag_toward_grabber()
	
func _drag_toward_grabber() -> void:
	print("is being dragged")
	# var target_x : float = _grabbed_by.global_position.x \
		# - _grabbed_by.facing_direction * grab_distance
	var target_x : float = _grabbed_by.global_position.x \
		- 1.0 * 1.0


	var distance := target_x - global_position.x

	var force := distance * 10#grab_strength
	force -= linear_velocity.x * 1.0# grab_damping

	print(force)
	force = clamp(force, -10000, 10000)
	#force = clamp(force, -max_grab_force, max_grab_force)

	apply_central_force(Vector2(force, 0.0))

func try_grab(_interactor: Node2D) -> void: 
	EventBus.try_grab.emit(self)

func grab(grabbed_by: Node2D) -> bool:
	if _grabbed_by != null:
		return false

	print("grabbed")
	_grabbed_by = grabbed_by
	return true

func release():
	print("released")
	_grabbed_by = null
