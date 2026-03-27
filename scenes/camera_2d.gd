extends Camera2D

@export var min_zoom := 0.5
@export var max_zoom := 3.0
@export var zoom_step := 0.1
@export var node: Node2D

var dragging := false
var last_pointer := Vector2.ZERO
## Tracks active touch positions by index for pinch-zoom.
var _touches: Dictionary = {}
var _pinch_start_distance: float = 0.0
var _pinch_start_zoom: float = 1.0


func _ready() -> void:
	make_current()
	set_process_input(false)
	GameState.game_started.connect(_on_game_started)


func _exit_tree() -> void:
	GameState.game_started.disconnect(_on_game_started)


func _on_game_started() -> void:
	set_process_input(true)


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and GameState.ui_open:
				return
			dragging = event.pressed
			last_pointer = event.position

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, -zoom_step)

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, zoom_step)

	elif event is InputEventMouseMotion and dragging:
		_drag(event.position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
		_update_touch_state()

	elif event is InputEventScreenDrag:
		# Use event.position only — event.relative is bugged on web with multitouch.
		_touches[event.index] = event.position
		if _touches.size() == 2:
			_handle_pinch()
		elif _touches.size() == 1 and dragging:
			_drag(event.position)



func _drag(p: Vector2):
	# Camera limits don't stop camera position from being changed.
	# This can lead to player being able to move the camera way past the screen and having to undo all his motions to get back to the playable area.
	# To stop this from happening we make sure that viewport edges cannot be moved outside the viewport.
	var diff := last_pointer - p
	var new_position := position + diff
	var center_offset = get_viewport_rect().size / 2.0 / zoom

	new_position.x = clamp(new_position.x, limit_left + center_offset.x, limit_right - center_offset.x)
	new_position.y = clamp(new_position.y, limit_top + center_offset.y, limit_bottom - center_offset.y)

	last_pointer = p
	position = position.lerp(new_position, 0.8)


func _update_touch_state() -> void:
	match _touches.size():
		0:
			dragging = false
		1:
			dragging = true
			last_pointer = _touches.values()[0]
		2:
			dragging = false
			var pts := _touches.values()
			_pinch_start_distance = (pts[0] as Vector2).distance_to(pts[1] as Vector2)
			_pinch_start_zoom = zoom.x
		_:
			dragging = false


func _handle_pinch() -> void:
	if _pinch_start_distance <= 0.0:
		return
	var pts := _touches.values()
	var p0 := pts[0] as Vector2
	var p1 := pts[1] as Vector2
	var current_distance: float = p0.distance_to(p1)
	var target_zoom: float = clamp(
			_pinch_start_zoom * (current_distance / _pinch_start_distance),
			min_zoom, max_zoom)
	var midpoint: Vector2 = (p0 + p1) / 2.0
	_zoom_at(midpoint, target_zoom / zoom.x - 1.0)


func _zoom_at(screen_pos: Vector2, amount: float):
	var new_zoom: float = clamp(zoom.x * (1.0 + amount), min_zoom, max_zoom)

	var vp := get_viewport()
	var before := vp.get_canvas_transform().affine_inverse() * screen_pos

	zoom = Vector2.ONE * new_zoom

	var after := vp.get_canvas_transform().affine_inverse() * screen_pos
	position += before - after
