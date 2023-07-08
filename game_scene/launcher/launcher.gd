extends Node2D

## The minimum length of time to wait, after the trigger area is entered, before starting pullback.
@export_range(0.3, 10.0, 0.1)
var settle_time_minimum := 1.0

## The maximum length of time to wait, after the trigger area is entered, before starting pullback.
@export_range(0.3, 60.0, 0.1)
var settle_time_maximum := 2.0

## The distance and direction to pull back.
@export
var pullback_vector := Vector2(0.0, 100.0)

## How long pullback should take.
@export_range(0.1, 10.0, 0.1)
var pullback_time := 1.0

## The minimum time to hold the plunger at maximum position.
@export_range(0.0, 5.0, 0.1)
var hold_time_minimum := 0.1

## The maximum time to hold the plunger at maximum position.
@export_range(0.0, 5.0, 0.1)
var hold_time_maximum := 0.5

## How long release should take.
@export_range(0.01, 1.0, 0.01)
var release_time := 0.25

## The minimum impulse to apply to the ball.
@export_range(100.0, 1000000.0, 100.0)
var impulse_minimum := 2000.0

## The maximum impulse to apply to the ball.
@export_range(100.0, 1000000.0, 100.0)
var impulse_maximum := 5000.0

## Whether a launch is currently taking place.
var _busy := false

## The trigger area.
@onready
var _trigger := $Area2D

## The sprite.
@onready
var _sprite := $Sprite2D

## The sound.
@onready
var _sound := $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	if _busy:
		return
	var bodies: Array[Node2D] = _trigger.get_overlapping_bodies()
	var rigid: RigidBody2D = null
	for body in bodies:
		rigid = body as RigidBody2D
		if rigid != null:
			break
	if rigid == null:
		return

	# Prevent multiple concurrent executions of the coroutine.
	_busy = true
	# Wait for the settle time, pull back the plunger, wait for the hold time, and release the
	# plunger.
	var tween := create_tween()
	tween.tween_interval(randf_range(settle_time_minimum, settle_time_maximum))
	tween.tween_property(_sprite, "position", pullback_vector, pullback_time) \
		.as_relative() \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(randf_range(hold_time_minimum, hold_time_maximum))
	tween.tween_callback(_sound.play)
	tween.tween_property(_sprite, "position", _sprite.position, release_time) \
		.set_ease(Tween.EASE_IN)
	await tween.finished
	# Push the ball.
	rigid.apply_central_impulse(Vector2(0, -randf_range(impulse_minimum, impulse_maximum)))
	# Wait three seconds to avoid false triggers.
	await get_tree().create_timer(3, false).timeout
	# Re-enable triggering.
	_busy = false
