class_name CameraBounds
extends Node2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func get_rect() -> Rect2:
	return collision_shape.shape.get_rect()
