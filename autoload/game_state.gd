extends Node
## Global game lifecycle state.
## Emit game_started once when the player presses Play.
## Call reset() before reloading the scene so objects start inactive again.

signal game_started
signal cat_discovered(found: int, total: int)
signal all_cats_found

var started: bool = false
var ui_open: bool = false
var total_cats: int = 0
var found_cats: int = 0


func start() -> void:
	if started:
		return
	started = true
	game_started.emit()


func register_cat() -> void:
	total_cats += 1


func on_cat_found() -> void:
	found_cats += 1
	cat_discovered.emit(found_cats, total_cats)
	if found_cats >= total_cats:
		all_cats_found.emit()


func reset() -> void:
	started = false
	ui_open = false
	total_cats = 0
	found_cats = 0
