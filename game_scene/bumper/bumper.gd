extends StaticBody2D

func _ready():
	$AnimatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.get_animation() == "bump":
		# Play bump animation once
		$AnimatedSprite2D.play("idle")
	# Otherwise, loop idle animation

# Event on ball contact
func ball_contact() -> void:
	# Play bump animation once
	$AnimatedSprite2D.play("bump")

	# Play bump sound effect once
	# Randomize the the pitch up to a semitone higher or lower
	# Use same sound effect as flipper press, but with lowered pitch
	var rng = RandomNumberGenerator.new()
	$AudioStreamPlayer2D.pitch_scale = rng.randf_range(0.943874, 1.059463)*.8
	$AudioStreamPlayer2D.play()
