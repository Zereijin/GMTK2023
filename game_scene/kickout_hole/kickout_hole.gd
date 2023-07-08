extends Area2D

## Emitted when the ball is captured by the hole.
signal captured()

## How much impulse to apply to the ball when it is kicked.
@export_range(100.0, 1000000.0, 100.0)
var impulse := 1000.0

func _ready():
	$AnimatedSprite2D.play("idle")

func _on_body_entered(body: Node2D) -> void:
	# Capture the ball
	var ball := body as Ball
	assert(ball != null)

	# Set ball position
	# Reset movement speed
	ball.global_position = global_position
	ball.linear_velocity = Vector2.ZERO

	# Make sleep and insensitive
	# NOTE: do this _after_ setting position and velocity
	ball.sensitive = false
	ball.sleeping = true

	# Play capture sound, with randomized pitch
	var rng = RandomNumberGenerator.new()
	$captureAudioStreamPlayer2D.pitch_scale = rng.randf_range(0.943874, 1.059463)
	$captureAudioStreamPlayer2D.play()

	# Play bonus sound
	$bonusAudioStreamPlayer2D.play()

	# Play capture animation
	$AnimatedSprite2D.play("captured")

	# Hide ball sprite in favour of captured ball baked into hole sprite.
	ball.visible = false

	# Give points.
	PlayerData.score_kickout_hole()

	# Announce.
	captured.emit()

	# Release the ball when bonus sound ends
	await $bonusAudioStreamPlayer2D.finished

	# Play kick sound, with randomized pitch
	$kickAudioStreamPlayer2D.pitch_scale = rng.randf_range(0.943874, 1.059463) * 0.8
	$kickAudioStreamPlayer2D.play()

	# Play idle animation
	$AnimatedSprite2D.play("idle")

	# Show ball sprite.
	ball.visible = true

	# Wake and make sensitive
	ball.sensitive = true
	ball.sleeping = false

	# Kick ball in random direction
	ball.apply_impulse(Vector2.from_angle(rng.randf_range(0, 2 * PI)) * impulse)
