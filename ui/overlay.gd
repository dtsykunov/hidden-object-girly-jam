extends Control

enum State {
	START,
	GAME,
	OPTIONS,
	HINTS,
}

@onready var _how_to_play_container: Control
@onready var _options_menu: CenterContainer = $OptionsMenu
@onready var _confirm_panel: CenterContainer = $ConfirmPanel
@onready var _victory_panel: CenterContainer = $VictoryPanel
@onready var _hint_book: HintBook = $HintBook
@onready var _cat_counter: Label = $CatCounter
@onready var _confetti: CPUParticles2D = $Confetti
@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SFXSlider

var _state: State = State.START
var _transitioning: bool = false
var _counter_tween: Tween

func _ready() -> void:
	_init_sliders()
	_cat_counter.pivot_offset = _cat_counter.size / 2.0
	GameState.cat_discovered.connect(_on_cat_discovered)
	GameState.all_cats_found.connect(_on_all_cats_found)
	_hint_book.close_requested.connect(_on_hints_book_button_pressed)

	if not OS.has_feature("mobile"):
		_how_to_play_container = %HowToPlayContainerDesktop
		%HowToPlayContainerMobile.hide()
	else:
		_how_to_play_container = %HowToPlayContainerMobile
		%HowToPlayContainerDesktop.hide()
	_how_to_play_container.show()


func _on_options_button_pressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	if _state == State.OPTIONS:
		_state = State.GAME
		GameState.ui_open = false
		await PanelAnimator.hide(_options_menu)
	else:
		if _state == State.HINTS:
			await PanelAnimator.hide(_hint_book)
		_state = State.OPTIONS
		GameState.ui_open = true
		PanelAnimator.show(_options_menu)
	_transitioning = false


func _on_hints_book_button_pressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	if _state == State.HINTS:
		_state = State.GAME
		GameState.ui_open = false
		await PanelAnimator.hide(_hint_book)
	else:
		if _state == State.OPTIONS:
			await PanelAnimator.hide(_options_menu)
		_state = State.HINTS
		GameState.ui_open = true
		PanelAnimator.show(_hint_book)
	_transitioning = false


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
	_state = State.GAME
	await PanelAnimator.dismiss(_how_to_play_container)
	_cat_counter.text = "Found: 0 / %d" % GameState.total_cats
	_cat_counter.show()


func _on_restart_button_pressed() -> void:
	await PanelAnimator.hide(_options_menu)
	PanelAnimator.show(_confirm_panel)


func _on_continue_button_pressed() -> void:
	PanelAnimator.hide(_options_menu)
	GameState.ui_open = false
	_state = State.GAME


func _on_confirm_cancel_pressed() -> void:
	PanelAnimator.hide(_confirm_panel)
	GameState.ui_open = false
	_state = State.GAME


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
	if _counter_tween:
		_counter_tween.kill()
	_cat_counter.scale = Vector2(1.3, 1.3)
	_counter_tween = create_tween()
	_counter_tween.set_ease(Tween.EASE_OUT)
	_counter_tween.set_trans(Tween.TRANS_SPRING)
	_counter_tween.tween_property(_cat_counter, "scale", Vector2.ONE, 0.6)


func _on_all_cats_found() -> void:
	_confetti.emitting = true
	PanelAnimator.show(_victory_panel)


func _on_victory_play_again_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
