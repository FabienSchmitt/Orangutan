class_name Lamppost
extends Node2D


@onready var selection_sprite : Sprite2D = %SelectionSprite
@onready var glow_sprite : Sprite2D = %GlowSprite
@onready var light2d : Light2D = %Light2D
var selected: bool = false
var is_lit: bool = false

func ready() -> void:
	selection_sprite.visible = false
	glow_sprite.visible = false
	light2d.visible = false

func _process(delta: float) -> void:
	if selected:
		selection_sprite.visible = true
	else:
		selection_sprite.visible = false

	if is_lit:
		glow_sprite.visible = true
		light2d.visible = true
	else:
		glow_sprite.visible = false
		light2d.visible = false
