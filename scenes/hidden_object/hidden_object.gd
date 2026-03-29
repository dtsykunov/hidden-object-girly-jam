class_name HiddenObject
extends Sprite2D
## A cat hidden in the scene. Brightens on hover, bounces and glows when found.

signal cat_found

@export var cat_data: CatData
@export var purr_sound: AudioStream
@export var meow_sound: AudioStream

@onready var _area: Area2D = $Area2D
@onready var _collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _purr_player: AudioStreamPlayer = $PurrPlayer
@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenEnabler2D
@onready var _glow_sprite: Sprite2D = $GlowSprite

var _is_found := false
var _base_scale := Vector2.ONE
var _base_modulate: Color
var _cat_index: int = -1
## Normalized scale multiplier driven by AnimationPlayer. 1.0 = base scale.
var bounce_scale: float = 1.0:
	set(v):
		bounce_scale = v
		scale = _base_scale * v


func _ready() -> void:
	_base_scale = scale
	_base_modulate = modulate

	if cat_data and cat_data.sprite:
		texture = cat_data.sprite
		_glow_sprite.texture = texture
		_glow_sprite.flip_h = flip_h
		_glow_sprite.flip_v = flip_v

	if texture:
		var shape := RectangleShape2D.new()
		shape.size = texture.get_size()
		_collision.shape = shape

	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)

	_notifier.screen_exited.connect(func() -> void: _glow_sprite.hide())
	_notifier.screen_entered.connect(func() -> void:
		if _is_found:
			_glow_sprite.show())

	_cat_index = GameState.register_cat(cat_data)


func _on_mouse_entered() -> void:
	if not GameState.started:
		return
	if not _is_found:
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color(1.3, 1.2, 1.0, 1.0), 0.15)
	if purr_sound and not _purr_player.playing:
		_purr_player.stream = purr_sound
		_purr_player.play()


func _on_mouse_exited() -> void:
	if not GameState.started:
		return
	if not _is_found:
		var tween := create_tween()
		tween.tween_property(self, "modulate", _base_modulate, 0.15)
	_purr_player.stop()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not GameState.started:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		if _is_found:
			_bounce()
		else:
			_discover()


func _discover() -> void:
	_is_found = true
	_purr_player.stop()
	if meow_sound:
		SoundManager.play_sfx(meow_sound)
	_start_glow_pulse()
	_bounce()
	cat_found.emit()
	GameState.on_cat_found(_cat_index)


func _start_glow_pulse() -> void:
	_glow_sprite.show()
	_glow_sprite.modulate.a = 1.0


func _bounce() -> void:
	_anim.stop()
	_anim.play("bounce")
