extends Area2D

@export() var replication_speed := 2.0
@export() var size := 50
@export() var max_size := 100

@onready var size_label : Label = $Label

var replication_timer : Timer

func _ready() -> void:
	replication_timer = Timer.new()
	replication_timer.wait_time = replication_speed  # seconds	
	replication_timer.autostart = true
	replication_timer.one_shot = false
	add_child(replication_timer)
	replication_timer.timeout.connect(_on_timer_timeout)


func _process(delta: float) -> void:
	if (size >= max_size) : return
	if (replication_timer.is_stopped()) :
		replication_timer.start()


func _on_timer_timeout() -> void:
	size += 1
	size_label.text = str(size)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT  and event.is_pressed():
		on_click()

func on_click():
	size /= 2
	size_label.text = str(size)
