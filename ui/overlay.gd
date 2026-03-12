extends Control

@onready var _play_button: Button = $PlayButton
@onready var _options_menu: CenterContainer = $OptionsMenu
@onready var _confirm_panel: CenterContainer = $ConfirmPanel
@onready var _victory_panel: CenterContainer = $VictoryPanel
@onready var _cat_counter: Label = $CatCounter
@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SFXSlider


func _ready() -> void:
	_init_sliders()
	GameState.cat_discovered.connect(_on_cat_discovered)
	GameState.all_cats_found.connect(_on_all_cats_found)


func _on_options_button_pressed() -> void:
	if _options_menu.visible:
		PanelAnimator.hide(_options_menu)
		GameState.ui_open = false
	else:
		PanelAnimator.show(_options_menu)
		GameState.ui_open = true


func _init_sliders() -> void:
	_set_slider_from_bus(_master_slider, "Master")
	_set_slider_from_bus(_music_slider, "Music")
	_set_slider_from_bus(_sfx_slider, "SFX")


func _set_slider_from_bus(slider: HSlider, bus_name: String) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	slider.set_block_signals(true)
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
	slider.set_block_signals(false)


func _on_master_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), _to_db(value))


func _on_music_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), _to_db(value))


func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), _to_db(value))


func _to_db(value: float) -> float:
	return -80.0 if value <= 0.0 else linear_to_db(value)


func _on_play_button_pressed() -> void:
	GameState.start()
	await PanelAnimator.dismiss(_play_button)
	_cat_counter.text = "Found: 0 / %d" % GameState.total_cats
	_cat_counter.show()


func _on_restart_button_pressed() -> void:
	await PanelAnimator.hide(_options_menu)
	PanelAnimator.show(_confirm_panel)


func _on_continue_button_pressed() -> void:
	PanelAnimator.hide(_options_menu)
	GameState.ui_open = false


func _on_confirm_cancel_pressed() -> void:
	PanelAnimator.hide(_confirm_panel)
	GameState.ui_open = false


func _on_confirm_restart_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()


func _on_fullscreen_button_pressed() -> void:
	var is_fullscreen := DisplayServer.window_get_mode() in [
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
	]
	var target := DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(target)


func _on_cat_discovered(found: int, total: int) -> void:
	_cat_counter.text = "Found: %d / %d" % [found, total]


func _on_all_cats_found() -> void:
	PanelAnimator.show(_victory_panel)


func _on_victory_play_again_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
