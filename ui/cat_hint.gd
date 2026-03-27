@tool
extends Control

@export var cat_data: CatData = null:
	set(new_data):
		cat_data = new_data
		if is_node_ready():
			$HiddenObjectTexture.texture = cat_data.sprite
			$HintLabel.text = cat_data.hint
