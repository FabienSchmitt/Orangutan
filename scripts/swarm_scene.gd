extends Node2D

func _ready() -> void:
    GameManager.create_grid()

func get_obstacle_cells() -> Array[UniformGridCell]:
    return []


