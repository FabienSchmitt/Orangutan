extends Node

@warning_ignore("unused_signal")
signal game_starts()

@warning_ignore("unused_signal")
signal player_score_added(scoreToAdd: int)

@warning_ignore("unused_signal")
signal player_life_lost(lifeToLose: int)

@warning_ignore("unused_signal")
signal player_life_gained(lifeToGain: int)

@warning_ignore("unused_signal")
signal game_is_over()

@warning_ignore("unused_signal")
signal controls_mixed()

@warning_ignore("unused_signal")
signal send_controls_mixed_warning()

@warning_ignore("unused_signal")
signal warning_played()

# signal tourist_has_been_hit(tourist: Tourist)