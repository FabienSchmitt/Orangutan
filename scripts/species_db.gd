class_name SpeciesDb
extends Resource

@export var species_list : Array[Species] = []

var _map := {}

# called from globals (autoload) : probably not ideal
func create_map():
	print("species_db: ", species_list)
	for s in species_list:        
		print("species : ", s.name)
		_map[s.name] = s
	for s_key in _map:
		set_predators_and_preys(s_key)

func get_species(name: String) -> Species:
	return _map.get(name)

func set_predators_and_preys(s_key: String) -> void:
	var species: Species = _map.get(s_key)
	for p in species.predator_names:
		species.predators.append(_map.get(p))
	for p in species.prey_names:
		species.preys.append(_map.get(p))
