class_name PanelAnimator


static func show(panel: Control) -> void:
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0.0
	panel.show()
	var tween := panel.create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.5) \
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)


static func hide(panel: Control) -> void:
	var tween := panel.create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(0.85, 0.85), 0.15) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tween.finished
	panel.hide()
	panel.scale = Vector2.ONE
	panel.modulate.a = 1.0


static func dismiss(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var tween := node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ZERO, 0.3) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, 0.25)
	await tween.finished
	node.hide()
	node.scale = Vector2.ONE
	node.modulate.a = 1.0
