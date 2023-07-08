extends StaticBody2D

## How much impulse to apply to the ball when it touches the bumper.
@export_range(100.0, 1000000.0, 100.0)
var impulse := 1000.0

@export
var bump_scaling_animation:CurveTexture;

# This is ugly but used to simplify the computation of the progress on
# the "bump" animation. The progress is then fed into the curve to
# figure out what the scale in that point of time for the pylon
var bump_frame_count_inverse:float;

func _ready():
	$AnimatedSprite2D.play("idle")
	
	# Figure out what fraction of time each frame of the animation should represent
	bump_frame_count_inverse = 1.0 / float($AnimatedSprite2D.sprite_frames.get_frame_count("bump"))

func _process(delta):
	if $AnimatedSprite2D.animation == "bump":
		var progress:float = float($AnimatedSprite2D.frame) * bump_frame_count_inverse + bump_frame_count_inverse * $AnimatedSprite2D.frame_progress
		var scale = bump_scaling_animation.curve.sample(progress)
		$AnimatedSprite2D.scale = Vector2(scale, scale);

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

	# Give some points.
	PlayerData.score_pylon()
