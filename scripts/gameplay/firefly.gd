extends Interactable

@export var path : Path2D
@export var speed : float = 500.0
@export var vertical_speed: float = 50

@onready var fly_audio_player : AudioStreamPlayer2D = %FlySoundPlayer
@onready var die_audio_player : AudioStreamPlayer = %DieSoundPlayer

var path_follow : PathFollow2D
var current_v_offset: float = 0.0
var target_v_offset: float = 0.0
var offset_direction: int = 1 # 1 for up, -1 for down
var active: bool = false
var path_completed: bool = false

signal arrived

func _ready() -> void:
	path_follow = PathFollow2D.new()
	path_follow.loop = false
	path.add_child(path_follow)
	arrived.connect(on_arrived)
	area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)


func _process(delta: float) -> void:
	if !active : 
		global_position = path_follow.global_position
		return 
	if !path_completed:
		path_follow.progress += speed * delta
		compute_vertical_offset(delta)
		global_position = path_follow.global_position


	if path_follow.progress_ratio >= 1.0:
		path_completed = true
		arrived.emit()

func reset() -> void:
	path_follow.progress = 0.0
	current_v_offset = 0.0
	target_v_offset = 0.0
	offset_direction = 1
	active = false
	path_completed = false
	fly_audio_player.stop()
	die_audio_player.play()

func interact() -> void:
	active = true
	fly_audio_player.play()

func compute_vertical_offset(delta: float) -> void:
	if current_v_offset < target_v_offset && offset_direction == 1:
		current_v_offset += vertical_speed * delta
	elif current_v_offset > target_v_offset && offset_direction == -1:
		current_v_offset -= vertical_speed * delta
	else : 
		target_v_offset = randf_range(-10.0, 10.0)
		offset_direction = 1 if target_v_offset > current_v_offset else -1

	path_follow.v_offset = current_v_offset

func on_area_entered(area: Area2D) -> void:
	print ("Area entered: ", area.name)
	if area.is_in_group("Obstacles"):
		print("Reset!")
		reset()

	if area.get_parent() is Lamppost:
		var lamppost = area.get_parent() as Lamppost
		if !lamppost.is_lit:
			lamppost.light_up()

func on_body_entered(body: Node) -> void:
	print ("body entered: ", body.name)
	if body.is_in_group("Obstacles"):
		print("Reset!")
		reset()	

func on_arrived() -> void:
	active = false
	queue_free()
