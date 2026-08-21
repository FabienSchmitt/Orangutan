class_name InteractComponent extends Area2D

@export var player: Player

var interactables: Array[Node] = []
var grabbed_object: MovingObject = null

func _ready() -> void:
	#interactables = get_tree().get_nodes_in_group("Interactables")
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	if player == null:
		player = get_parent() as Player
	EventBus.try_grab.connect(try_grab)
	EventBus.force_release.connect(release)


func _process(_delta: float) -> void:
	# if we are grabbing we need to maintain the grab
	if grabbed_object != null:
		if ! Input.is_action_pressed("interact"):
			release()
		# we return as we are in a grabbing situation.
		return
	
	# we only interact with the first interactable in the list, if any
	if Input.is_action_just_pressed("interact"):		
		for interactable in interactables:
			# check if the interactable is still valid (not freed)
			if !is_instance_valid(interactable):
				continue

			if interactable is Interactable:
				interactable.interact(self)
				return

func try_grab(moving_object: MovingObject):
	if player.can_grab():
		grab(moving_object)

func grab(moving_object: MovingObject):
	if moving_object.grab(self):
		grabbed_object = moving_object
		
func release():
	grabbed_object.release()
	grabbed_object = null

func _on_area_entered(area: Area2D) -> void:
	print("area appended")
	if area.is_in_group("Interactables"):
		interactables.append(area)
		
func _on_area_exited(area: Area2D) -> void:
	print("area erased")
	if area.is_in_group("Interactables"):
		interactables.erase(area)
