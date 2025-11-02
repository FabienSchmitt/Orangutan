class_name Species
extends RefCounted

@export var color : Color = Color.GRAY
@export var name : String = "Neutral"

var cells: Array[Cell] = []

func _init(p_color: Color, p_name: String) -> void:
    color = p_color 
    name = p_name

