extends Node

var start_score: int = 0
var start_life: int = 10
var is_game_over = false
var current_score: int = 0
var current_life: int = 10
var score_history: Array[int] = []
var is_multiplayer := true

func start_game():
	EventBus.game_starts.emit()
	AudioManager.change_music(preload("res://assets/music/main-theme.wav"))

func reset_game() -> void:
	reset_score()
	reset_life()
	is_game_over = false

func reset_score() -> void:
	current_score = start_score

func reset_life() -> void:
	current_life = start_life

func add_score(value: int) -> void:
	if is_game_over:
		return
	current_score += value

func add_current_score_to_history() -> void:
	score_history.append(current_score)

func get_best_score() -> int:
	var start_index: int = max(0, score_history.size() - 1)
	if score_history.is_empty():
		return 0

	var best_score: int = score_history[start_index]
	for index in range(start_index + 1, score_history.size()):
		if score_history[index] > best_score:
			best_score = score_history[index]
	return best_score

func lose_life(value: int) -> void:
	if is_game_over:
		return
		
	if current_life > 0:
		current_life -= value
	if current_life < 0:
		current_life = 0    
	if current_life == 0:
		is_game_over = true
		add_current_score_to_history()
		EventBus.game_is_over.emit()

func add_life(value: int) -> void:
	if is_game_over:
		return
	current_life += value

func change_player_control():
	MultiplayerHandler.mix_controls()