class_name Species
extends RefCounted

@export var color : Color
@export var name : String

func _init(p_color: Color, p_name: String) -> void:
    color = p_color 
    name = p_name

