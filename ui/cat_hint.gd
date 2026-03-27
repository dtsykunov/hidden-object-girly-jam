@tool
extends Control

@export var cat_data: CatData = null:
	set(new_data):
		cat_data = new_data
		if is_node_ready():
			_refresh()


func _ready() -> void:
	if not Engine.is_editor_hint():
		GameState.cat_registry_updated.connect(_refresh)
	_refresh()


func _refresh() -> void:
	if cat_data == null:
		return
	$HiddenObjectTexture.texture = cat_data.sprite
	$HintLabel.text = cat_data.hint
	var found := not Engine.is_editor_hint() and GameState.is_cat_found(cat_data)
	$HiddenObjectTexture.modulate = Color.WHITE if found else Color.BLACK
