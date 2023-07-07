extends StaticBody2D

func _ready():
	$AnimatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.get_animation() == "bump":
		# Play bump animation once
		$AnimatedSprite2D.play("idle")
	# Otherwise, loop idle animation

# Event on ball contact
func ball_contact():
	# Play bump animation once
	$AnimatedSprite2D.play("bump")
