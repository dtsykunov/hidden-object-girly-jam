extends Node
## Global game lifecycle state.
## Emit game_started once when the player presses Play.
## Call reset() before reloading the scene so objects start inactive again.

signal game_started

var started: bool = false


func start() -> void:
	if started:
		return
	started = true
	game_started.emit()


func reset() -> void:
	started = false
