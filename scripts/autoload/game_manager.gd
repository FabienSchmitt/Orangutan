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
	AudioManager.change_music(preload("res://assets/audio/music/jungle-drums.mp3"))

func reset_game() -> void:
	reset_score()
	reset_life()
	is_game_over = false

func reset_score() -> void:
	current_score = start_score

func reset_life() -> void:
	current_life = start_life


func lose_life(value: int) -> void:
	if is_game_over:
		return
		
	if current_life > 0:
		current_life -= value
	if current_life < 0:
		current_life = 0    
	if current_life == 0:
		is_game_over = true
		EventBus.game_is_over.emit()
