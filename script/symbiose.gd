class_name Symbiose_Manager
extends Resource

var species_1 : Species
var species_2 : Species
var _cells_1: Array[Cell]
var _cells_2: Array[Cell]
var connections: Array [Connection]
var tmp_connections: Array[Connection]

func create_connections() -> void:
    connections = []
    tmp_connections = []
    _cells_1 = GameManager.get_cells(species_1)
    _cells_2 = GameManager.get_cells(species_2)
    compute_all_connections()
    filter_connections()


func compute_all_connections(): 
    var connection : Connection
    for c1 in _cells_1:
        for c2 in _cells_2:
            connection = Connection.new(GameManager.Behaviors.SYMBIOSE, c1, c2, )
            tmp_connections.append(connection)
                
func filter_connections() -> void:
   
    for cell_1 in _cells_1:
        append_closest_connection(cell_1)

    for cell_2 in _cells_2:
        if connections.any(func(c): return c.target == cell_2): pass # this behavior could change in the future.
        append_closest_connection(cell_2)
        

func append_closest_connection(cell: Cell):
    var con : Array[Connection]
    con = tmp_connections.filter(func(c): return c.source == cell)
    con.sort_custom(func(c1, c2): return c1.distance < c2.distance)
    connections.append(con[0])

        

