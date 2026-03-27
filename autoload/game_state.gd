extends Node
## Global game lifecycle state.
## Emit game_started once when the player presses Play.
## Call reset() before reloading the scene so objects start inactive again.

signal game_started
signal cat_discovered(found: int, total: int)
signal all_cats_found
signal cat_registry_updated

var started: bool = false
var ui_open: bool = false
var total_cats: int = 0
var found_cats: int = 0
## Each entry: { cat_data: CatData, is_found: bool }
var cat_entries: Array = []


func start() -> void:
	if started:
		return
	started = true
	game_started.emit()


## Registers a cat and returns its index for use in on_cat_found().
func register_cat(cat_data: CatData) -> int:
	var idx := cat_entries.size()
	cat_entries.append({"cat_data": cat_data, "is_found": false})
	total_cats += 1
	return idx


func on_cat_found(index: int) -> void:
	if index >= 0 and index < cat_entries.size():
		cat_entries[index].is_found = true
	found_cats += 1
	cat_discovered.emit(found_cats, total_cats)
	cat_registry_updated.emit()
	if found_cats >= total_cats:
		all_cats_found.emit()


func is_cat_found(cat: CatData) -> bool:
	for entry in cat_entries:
		if entry.cat_data == cat:
			return entry.is_found
	return false


func reset() -> void:
	started = false
	ui_open = false
	total_cats = 0
	found_cats = 0
	cat_entries.clear()
