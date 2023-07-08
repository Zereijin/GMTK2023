extends StaticBody2D

## How much impulse to apply to the ball when it touches the bumper.
@export_range(100.0, 1000000.0, 100.0)
var impulse := 1000.0

func _ready():
	$AnimatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.get_animation() == "bump":
		# Play bump animation once
		$AnimatedSprite2D.play("idle")
	# Otherwise, loop idle animation

# Event on ball contact
func ball_contact(ball: Ball) -> void:
	# Play bump animation once
	$AnimatedSprite2D.play("bump")

	# Play bump sound effect once
	# Randomize the the pitch up to a semitone higher or lower
	var rng = RandomNumberGenerator.new()
	$AudioStreamPlayer2D.pitch_scale = rng.randf_range(0.943874, 1.059463)
	$AudioStreamPlayer2D.play()

	# Push the ball.
	ball.apply_impulse(global_position.direction_to(ball.global_position) * impulse)
