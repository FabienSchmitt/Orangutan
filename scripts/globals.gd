extends Node

var swarm_factory: SwarmFactory = SwarmFactory.new()
var species_db: SpeciesDb

func _ready():
    species_db = load("res://resources/species/species_db.tres")
    species_db.create_map()