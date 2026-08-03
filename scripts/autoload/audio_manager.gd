extends Node
var music_player : AudioStreamPlayer = AudioStreamPlayer.new()
var effects_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	music_player.stream = preload("res://assets/audio/music/jungle-drums.mp3")
	music_player.bus = "Music"
	add_child(music_player)

	effects_player.bus = "Effects"
	add_child(effects_player)

	# Keep music playing while the scene tree is paused
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	effects_player.process_mode = Node.PROCESS_MODE_ALWAYS

	# Start playback and loop when finished
	music_player.play()
	music_player.finished.connect(func() -> void:
		music_player.play())

	
	EventBus.lit_light.connect(play_effect.bind(preload("res://assets/audio/sound_effects/fire-whoosh.mp3"), 0.5))


func change_music(audio_stream: AudioStream) -> void:
	music_player.stream = audio_stream
	music_player.play()

func play_effect(audio_stream: AudioStream, offset: float = 0.0) -> void:
	effects_player.stream = audio_stream
	effects_player.play(offset)
