extends Node2D

@onready var polygon : Polygon2D= %Polygon2D
@onready var line : Line2D = %Line2D
@onready var collision : CollisionPolygon2D = %CollisionPolygon2D

func _ready() -> void:
	line.points = polygon.polygon
	collision.polygon = polygon.polygon
