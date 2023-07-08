extends Area2D

## Emitted when the game is over.
signal game_over()

## The fuel manager.
@export
var fuel_manager: FuelManager

## The ball.
@export
var ball: Ball

## The initial position of the ball.
@onready
var _initial_ball_position := ball.position

## The clip to play when draining the ball.
@onready
var _audio := $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	var ball := body as Ball
	assert(ball != null)
	ball.sensitive = false
	ball.sleeping = true
	_audio.play()
	await _audio.finished
	if fuel_manager.use_ball():
		ball.position = _initial_ball_position
		ball.linear_velocity = Vector2.ZERO
		await get_tree().physics_frame
		ball.sleeping = false
		ball.sensitive = true
	else:
		game_over.emit()
