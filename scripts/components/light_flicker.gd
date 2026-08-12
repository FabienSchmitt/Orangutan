class_name LightFlicker extends PointLight2D


@export var flicker_intensity: float = 0.1
@export var flicker_frequency: float = 0.2
var original_energy: float = 1.0

func _ready() -> void:
	original_energy = energy
	flicker()

func flicker():
	var new_value := randf_range(-1, 1) * flicker_intensity
	energy = original_energy + new_value

	await get_tree().create_timer(flicker_frequency * (1+ randf_range(-0.3 , 0.3))).timeout
	flicker()
