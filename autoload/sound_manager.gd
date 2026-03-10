extends Node

const MUSIC_TRACK := preload("res://assets/music/Casual Field Day Main.wav")

@onready var _music_player: AudioStreamPlayer = $MusicPlayer


func play_music(stream: AudioStream = MUSIC_TRACK) -> void:
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
