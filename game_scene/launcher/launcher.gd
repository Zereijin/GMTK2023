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

## The solid body.
@onready
var _body := $AnimatableBody2D

## The pullback sound.
@onready
var _pullback_sound := $pullback_player

## The fire sound.
@onready
var _fire_sound := $fire_player

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
	# Wait for the settle time.
	var tween := create_tween()
	tween.tween_interval(randf_range(settle_time_minimum, settle_time_maximum))
	# Pull back the plunger (playing the pullback sound). Move the body with it, to lower the ball.
	var body_orig_pos: Vector2 = _body.position
	tween.tween_callback(_pullback_sound.play)
	tween.tween_property(_sprite, "position", pullback_vector, _pullback_sound.stream.get_length()) \
		.as_relative() \
		.set_ease(Tween.EASE_IN_OUT)
	tween.parallel()
	tween.tween_property(_body, "position", pullback_vector, _pullback_sound.stream.get_length()) \
		.as_relative() \
		.set_ease(Tween.EASE_IN_OUT)
	# Wait for the hold time.
	tween.tween_interval(randf_range(hold_time_minimum, hold_time_maximum))
	# Release the plunger (playing the fire sound and pushing the ball).
	tween.tween_callback(_fire_sound.play)
	tween.tween_property(_sprite, "position", _sprite.position, release_time) \
		.set_ease(Tween.EASE_IN)
	await tween.finished
	# Push the ball.
	rigid.apply_central_impulse(Vector2(0, -randf_range(impulse_minimum, impulse_maximum)))
	# Update player data.
	if not PlayerData.first_launch:
		PlayerData.score_relaunch()
	PlayerData.first_launch = false
	# Move the collision body back afterwards, to avoid interfering with the launching ball.
	_body.position = body_orig_pos
	# Wait a couple of physics frames so the linear velocity estimate can update.
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Zero the velocity estimate so that it doesn’t bounce things that land on it now.
	_body.constant_linear_velocity = Vector2.ZERO
	# Wait three seconds to avoid false triggers.
	await get_tree().create_timer(3, false).timeout
	# Re-enable triggering.
	_busy = false
