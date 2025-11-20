class_name Species
extends Resource

@export var color : Color = Color.GRAY
@export var name : String = "Neutral"
@export var predators : Array[String] = []
@export var preys : Array[String] = []
@export var has_queen := false
@export var boids_weight: float = 2
@export var align_weight: float = 0.5
@export var cohesion_weight: float = 2
@export var avoid_weight: float = 20
@export var queen_weight: float = 0
@export var fleeing_weight: float = 20
@export var chasing_weight: float = 0
@export var visibility_threshold := 75
@export var boids_size := 50
@export var starting_speed := 100
@export var max_speed := 400
@export var max_chased_speed := 600
