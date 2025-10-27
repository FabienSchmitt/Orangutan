extends Area2D
class_name Cell

@export var replication_speed := 2.0
@export var size := 50
@export var max_size := 100
@export var swarm_factory : SwarmFactory

@onready var size_label : Label = $Label
@onready var _selected_circle : Sprite2D  = %SelectedCircle
@onready var swarm_multimesh : MultiMeshInstance2D = %SwarmMeshInstance


var _replication_timer : Timer

func _ready() -> void:
	_replication_timer = Timer.new()
	_replication_timer.wait_time = replication_speed  # seconds	
	_replication_timer.autostart = true
	_replication_timer.one_shot = false
	add_child(_replication_timer)
	_replication_timer.timeout.connect(_on_timer_timeout)
	

	_selected_circle.visible = false


func _process(delta: float) -> void:
	if (size >= max_size) : return
	if (_replication_timer.is_stopped()) :
		_replication_timer.start()


func _on_timer_timeout() -> void:
	size += 1
	size_label.text = str(size)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT  and event.is_pressed():
		GameManager.attack_cell(self)

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		GameManager.add_selected_cell(self)


func on_click():
	#create_swarm_multi_mesh()
	pass

func attack(target: Cell):
	var swarm_size = size/2
	size -= swarm_size
	var swarm = swarm_factory.create_swarm(self, target, swarm_size)
	get_tree().current_scene.add_child(swarm)
	size_label.text = str(size)

# func create_swarm_multi_mesh():
# 	var swarm_size = size/2
# 	size -= swarm_size
# 	size_label.text = str(size)
# 	swarm_multimesh.spawn_swarm(self.position, swarm_size)

func select(selected: bool) -> void:
	_selected_circle.visible = selected

func damage() -> void:
	size -= 1
	size_label.text = str(size)
