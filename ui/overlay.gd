extends Control

@onready var _options_menu: CenterContainer = $OptionsMenu
@onready var _restart_confirmation: ConfirmationDialog = $RestartConfirmation
@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SFXSlider


func _ready() -> void:
	_init_sliders()


func _on_options_button_pressed() -> void:
	_options_menu.visible = not _options_menu.visible


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


func _on_restart_button_pressed() -> void:
	_restart_confirmation.popup_centered()


func _on_continue_button_pressed() -> void:
	_on_options_button_pressed()


func _on_fullscreen_button_pressed() -> void:
	var is_fullscreen := DisplayServer.window_get_mode() in [
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
	]
	var target := DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(target)


func _on_restart_confirmed() -> void:
	get_tree().reload_current_scene()
