class_name HintBook
extends Control
## Picture book showing all cats.
##
## Unfound cats appear as black silhouettes with a hint label.
## Found cats show their normal image with no label.
## Call populate() each time the book is opened to reflect the latest state.

@onready var _tabs: TabContainer = $PanelContainer/TabContainer

func _ready() -> void:
	_tabs.tab_changed.connect(_on_tab_changed)

func _on_left_button_pressed() -> void:
	_tabs.select_previous_available()

func _on_right_button_pressed() -> void:
	_tabs.select_next_available()

func _on_tab_changed(tab_idx: int) -> void:
	if tab_idx == 0:
		%LeftButton.hide()
	else:
		%LeftButton.show()

	if tab_idx == 10:
		%RightButton.hide()
	else:
		%RightButton.show()

func _on_close_button_pressed() -> void:
	print("close button")
