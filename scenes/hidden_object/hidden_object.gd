class_name HiddenObject
extends Sprite2D
## A cat hidden in the scene. Glows on hover, bounces and meows when found.

signal cat_found

@export var cat_data: CatData
@export var purr_sound: AudioStream
@export var meow_sound: AudioStream
@export var MAX_GLOW: float = 10.0

@onready var _area: Area2D = $Area2D
@onready var _collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _purr_player: AudioStreamPlayer = $PurrPlayer
@onready var _anim: AnimationPlayer = $AnimationPlayer

var _is_found := false
var _base_scale := Vector2.ONE
## Normalized scale multiplier driven by AnimationPlayer. 1.0 = base scale.
var bounce_scale: float = 1.0:
	set(v):
		bounce_scale = v
		scale = _base_scale * v


func _ready() -> void:
	_base_scale = scale

	if cat_data and cat_data.sprite:
		texture = cat_data.sprite

	if texture:
		var shape := RectangleShape2D.new()
		shape.size = texture.get_size()
		_collision.shape = shape

	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)

	GameState.register_cat()


func _on_mouse_entered() -> void:
	if not GameState.started or _is_found:
		return
	_set_glow(0.6)
	if purr_sound and not _purr_player.playing:
		_purr_player.stream = purr_sound
		_purr_player.play()


func _on_mouse_exited() -> void:
	if not GameState.started or _is_found:
		return
	_set_glow(0.0)
	_purr_player.stop()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not GameState.started or _is_found:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		_discover()


func _discover() -> void:
	_is_found = true
	_purr_player.stop()
	if meow_sound:
		SoundManager.play_sfx(meow_sound)
	_set_glow(1.0)
	_bounce()
	cat_found.emit()
	GameState.on_cat_found()


func _set_glow(target: float) -> void:
	var from: float = material.get_shader_parameter("width")
	var tween := create_tween()
	tween.tween_method(
			func(v: float) -> void: material.set_shader_parameter("width", v),
			from, MAX_GLOW * target, 0.25)


func _bounce() -> void:
	_anim.play("bounce")
