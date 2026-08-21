class_name Interactable
extends Area2D

signal interacted(interactor: Node2D)

# interactor will mostly only be the player.
func interact(interactor: Node2D) -> void:
	interacted.emit(interactor)
