extends Sprite2D


func _ready() -> void:
	$PickableArea2D.input_event.connect(_on_pickable_area_2d_input_event)


func _on_pickable_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			$AnimationPlayer.play("spin")
		elif event.is_released():
			$AnimationPlayer.stop()

	if event is InputEventScreenTouch:
		pass
