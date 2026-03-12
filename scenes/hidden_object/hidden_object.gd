class_name HiddenObject
extends Sprite2D
## A cat hidden in the scene. Glows on hover, bounces and meows when found.

signal cat_found

@export var purr_sound: AudioStream
@export var meow_sound: AudioStream
@export var glow_color: Color = Color(1.0, 0.85, 0.2, 1.0)

@onready var _area: Area2D = $Area2D
@onready var _collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _purr_player: AudioStreamPlayer = $PurrPlayer

var _is_found := false
var _glow_material: ShaderMaterial

const _GLOW_SHADER := preload("res://scenes/hidden_object/cat_glow.gdshader")


func _ready() -> void:
	_glow_material = ShaderMaterial.new()
	_glow_material.shader = _GLOW_SHADER
	_glow_material.set_shader_parameter("glow_color", glow_color)
	_glow_material.set_shader_parameter("glow_strength", 0.0)
	_glow_material.set_shader_parameter("glow_size", 4.0)
	material = _glow_material

	if texture:
		var shape := RectangleShape2D.new()
		shape.size = texture.get_size()
		_collision.shape = shape

	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)

	GameState.register_cat()


func _on_mouse_entered() -> void:
	if _is_found:
		return
	_set_glow(0.6)
	if purr_sound and not _purr_player.playing:
		_purr_player.stream = purr_sound
		_purr_player.play()


func _on_mouse_exited() -> void:
	if _is_found:
		return
	_set_glow(0.0)
	_purr_player.stop()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_found:
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
	var from: float = _glow_material.get_shader_parameter("glow_strength")
	var tween := create_tween()
	tween.tween_method(
			func(v: float) -> void: _glow_material.set_shader_parameter("glow_strength", v),
			from, target, 0.25)


func _bounce() -> void:
	var original := scale
	var tween := create_tween()
	tween.tween_property(self, "scale", original * 1.35, 0.15) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original, 0.5) \
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
