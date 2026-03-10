extends Camera2D

@export var min_zoom := 0.5
@export var max_zoom := 3.0
@export var zoom_step := 0.1
@export var node: Node2D

var dragging := false
var last_pointer := Vector2.ZERO


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_pointer = event.position

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, -zoom_step)

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, zoom_step)

	elif event is InputEventMouseMotion and dragging:
		_drag(event.position)

	elif event is InputEventScreenTouch:
		dragging = event.pressed
		last_pointer = event.position

	elif event is InputEventScreenDrag and dragging:
		_drag(event.position)

	elif event is InputEventMagnifyGesture:
		_zoom_at(event.position, event.factor - 1.0)


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


func _zoom_at(screen_pos: Vector2, amount: float):
	var new_zoom: float = clamp(zoom.x * (1.0 + amount), min_zoom, max_zoom)

	var vp := get_viewport()
	var before := vp.get_canvas_transform().affine_inverse() * screen_pos

	zoom = Vector2.ONE * new_zoom

	var after := vp.get_canvas_transform().affine_inverse() * screen_pos
	position += before - after
