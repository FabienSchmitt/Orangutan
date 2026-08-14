extends Area2D

var interactables: Array[Node] = []

func _ready() -> void:
	interactables = get_tree().get_nodes_in_group("Interactables")
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _process(delta: float) -> void:
	# we only interact with the first interactable in the list, if any
	if Input.is_action_just_pressed("interact"):		
		for interactable in interactables:
			# check if the interactable is still valid (not freed)
			if !is_instance_valid(interactable):
				continue

			if interactable is Interactable:
				interactable.interact()
				return

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Interactables"):
		interactables.append(area)
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Interactables"):
		interactables.erase(area)
