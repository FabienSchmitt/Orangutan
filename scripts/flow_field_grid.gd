class_name FlowFieldGrid
extends UniformGrid

# --- Access methods ---
func set_cost(pos: Vector2i, cost: float) -> void:
	if cells.has(pos):
		cells[pos]["cost"] = cost

func reset(default_cost := INF):
	for pos in cells.keys():
		cells[pos].cost = default_cost
		cells[pos].flow = Vector2.ZERO