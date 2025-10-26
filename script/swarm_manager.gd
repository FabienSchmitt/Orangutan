extends MultiMeshInstance2D

var points = [] # store per-point data
var speed = 100.0
var target_position : Vector2

func _ready():
	var mesh = SphereMesh.new()
	mesh.radius = 5.0
	mesh.height = 10.0
	multimesh.mesh = mesh
	
func spawn_swarm(spawn_position: Vector2, count : int):
	var start_idx = multimesh.instance_count
	multimesh.instance_count += count
	for i in range(count):
		var angle = randf() * TAU
		var radius = randf() * 50.0
		var pos = spawn_position + Vector2(cos(angle), sin(angle)) * radius
		multimesh.set_instance_transform_2d(start_idx + i, Transform2D(0, pos))
		var color = Color(randf(), randf(), 0, 1) 
		multimesh.set_instance_color(start_idx + i, color)
		points.append({ "pos": pos, "target": target_position })


func _process(delta):
	
	for i in range(multimesh.instance_count):
		var p = points[i]
		var dir = (p.target - p.pos).normalized()
		p.pos += dir * speed * delta
		multimesh.set_instance_transform_2d(i, Transform2D(0, p.pos))

		# Optionally: fade or remove when near target
		if p.pos.distance_to(p.target) < 5.0:
			# could mark for removal
			pass
	
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
