class_name MovingObject 
extends RigidBody2D

@export var interactable: Interactable

var _is_grabbed := false

func _ready() -> void:
	interactable.interacted.connect(on_interacted)

func on_interacted():
	grab()

func grab():
	_is_grabbed = !_is_grabbed
	EventBus.object_grabbed.emit(self, _is_grabbed)
