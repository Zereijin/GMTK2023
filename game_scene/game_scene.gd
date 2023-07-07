extends Node2D

func _ready() -> void:
	var ball := $ball as RigidBody2D
	ball.apply_central_impulse(Vector2(0, -200))
