class_name Lamppost
extends Node2D

@export var max_light_energy := 2.0
@export var max_glow_offset := 10.0
@export var max_pulse_rate: float = 3
@export var min_pulse_rate: float = 8
@onready var selection_sprite : Sprite2D = %SelectionSprite
@onready var glow_sprite : Sprite2D = %GlowSprite
@onready var light2d : Light2D = %Light2D


var selected: bool = false
var is_lit: bool = false
var _light_energy: float = 0.0
var glow_modulate_a: float = 0.0
var _pulse_duration: float = 0.0


var offset: float = 0.05

func ready() -> void:
	light_down()
	selection_sprite.visible = false
	light2d.energy = _light_energy

	# flickering initialization
	offset = randf_range(5.0, max_glow_offset) / 100.0	
	_pulse_duration = randf_range(min_pulse_rate, max_pulse_rate)

func _process(delta: float) -> void:
	if selected:
		selection_sprite.visible = true
	else:
		selection_sprite.visible = false
	
	if (is_lit):
		pulse()


func light_up() -> void:
	print ("Lamppost light up")
	if is_lit:
		return
	# add to group before emittting event
	self.add_to_group("YellowFog")
	EventBus.lit_light.emit()
	_pulse_duration = randf_range(min_pulse_rate, max_pulse_rate)
	is_lit = true
	var light_tween = get_tree().create_tween()
	var current_color = glow_sprite.modulate
	glow_sprite.visible = true
	light2d.visible = true
	
	var target_color = Color(current_color.r, current_color.g, current_color.b, 1.0)
	light_tween.parallel().tween_property(glow_sprite, "modulate", target_color,3.0)
	light_tween.parallel().tween_property(light2d, "energy", max_light_energy, 3.0)


func light_down() -> void:
	if is_lit == false:
		return

	EventBus.unlit_light.emit()
	is_lit = false
	glow_sprite.visible = false
	light2d.visible = false
	_light_energy = 0.0
	glow_sprite.modulate.a = 0.0
	self.remove_from_group("YellowFog")

func pulse() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	glow_sprite.scale = Vector2.ONE * (1.0 + offset * sin(TAU * t / _pulse_duration))