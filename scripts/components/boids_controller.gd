extends Area2D


@export var player: Player
@export var reach_length := 200.0


var _boids: Array[Boids] = []
var _reachable_lampposts: Array[Lamppost] = []
var _selected_lamppost: Lamppost = null
var _lit_lamppost: Lamppost = null

func _ready() -> void:
	var boids = get_tree().get_nodes_in_group("Boids")
	for b in boids:
		if b is Boids:
			_boids.append(b)

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func  _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if _selected_lamppost != null:
			lit_selected_lamppost()
			

	if _reachable_lampposts.size() == 0:
		_selected_lamppost = null
		return

	if Input.is_action_just_pressed("select_next"):
		select_next_lamppost(1)

	if Input.is_action_just_pressed("select_previous"):
		select_next_lamppost(-1)

func lit_selected_lamppost() -> void:
	var boid = _boids[0]
	boid.change_queen(_selected_lamppost)
	if _lit_lamppost != null:
		_lit_lamppost.light_down()
	_lit_lamppost = _selected_lamppost
	_selected_lamppost.light_up()

func select_next_lamppost(direction : int) -> void:
	if _selected_lamppost == null:
		select_lampPost(_reachable_lampposts[0])
		return
		
	var index = _reachable_lampposts.find(_selected_lamppost)
	index = (index + direction) % _reachable_lampposts.size()
	select_lampPost(_reachable_lampposts[index])

func select_lampPost(lampPost: Lamppost) -> void:
	if self._selected_lamppost != null:
		self._selected_lamppost.selected = false
	_selected_lamppost = lampPost
	_selected_lamppost.selected = true


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Lamppost:
		var lampPost = area.get_parent() as Lamppost
		_reachable_lampposts.append(lampPost)

		if _selected_lamppost == null:
			select_lampPost(lampPost)

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() is Lamppost:
		_reachable_lampposts.erase(area.get_parent())
		if _selected_lamppost == area.get_parent():
			_selected_lamppost.selected = false
			_selected_lamppost = null
