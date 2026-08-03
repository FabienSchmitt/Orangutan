extends Camera2D

@export var random_strength := 30.0
@export var shake_fade := 5.0

var rng = RandomNumberGenerator.new()

var shake_strength := 0.0

func _ready() -> void:
	# Connect to the lit_light signal from the EventBus
	EventBus.lit_light.connect(_on_lit_light)

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		if shake_strength < 0.0:
			shake_strength = 0.0
		offset = random_offset()

func _on_lit_light() -> void:
	shake_strength = random_strength

func random_offset() -> Vector2:
	var offset_x = rng.randf_range(-shake_strength, shake_strength)
	var offset_y = rng.randf_range(-shake_strength, shake_strength)
	return Vector2(offset_x, offset_y)