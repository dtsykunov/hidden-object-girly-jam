class_name HintBook
extends CenterContainer
## Picture book showing all cats.
##
## Unfound cats appear as black silhouettes with a hint label.
## Found cats show their normal image with no label.
## Call populate() each time the book is opened to reflect the latest state.

@onready var _tabs: TabContainer = $PanelContainer/TabContainer

const CATS_PER_PAGE := 3
const CATS_PER_SPREAD := CATS_PER_PAGE * 2


func populate() -> void:
	for child in _tabs.get_children():
		_tabs.remove_child(child)
		child.queue_free()

	var entries: Array = GameState.cat_entries
	if entries.is_empty():
		return

	var spread_count := ceili(entries.size() / float(CATS_PER_SPREAD))
	for spread_idx in spread_count:
		_tabs.add_child(_make_spread(spread_idx, entries))


func _make_spread(spread_idx: int, entries: Array) -> Control:
	var start := spread_idx * CATS_PER_SPREAD
	var end := mini(start + CATS_PER_SPREAD, entries.size())

	var tab := Control.new()
	tab.name = "Cats%d_%d" % [start + 1, end]

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tab.add_child(hbox)

	for page_idx in 2:
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)

		for slot_idx in CATS_PER_PAGE:
			var global_idx := start + page_idx * CATS_PER_PAGE + slot_idx
			if global_idx < entries.size():
				var entry: Dictionary = entries[global_idx]
				_add_cat_slot(vbox, entry.cat_data, entry.is_found)
			else:
				_add_empty_slot(vbox)

	return tab


func _add_cat_slot(parent: VBoxContainer, cat_data: CatData, is_found: bool) -> void:
	var slot := VBoxContainer.new()
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(slot)

	var tex_rect := TextureRect.new()
	tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if cat_data:
		tex_rect.texture = cat_data.sprite
	if not is_found:
		tex_rect.modulate = Color.BLACK
	slot.add_child(tex_rect)

	if not is_found:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = cat_data.hint if (cat_data and not cat_data.hint.is_empty()) else "???"
		slot.add_child(label)


func _add_empty_slot(parent: VBoxContainer) -> void:
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(spacer)
