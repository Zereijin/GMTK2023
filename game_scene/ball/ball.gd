extends RigidBody2D

## The magnitude of impulse to apply each time the bump action is activated. Should be positive.
## Higher means more bump.
@export
var bump_impulse := 200.0

## The scaling factor from velocity to applied force when drag mode is activated. Should be
## negative. Larger magnitude means more drag.
@export
var drag_factor := -10.0

## A mapping from bump action names to directional impulse vectors.
@onready
var bump_impulses := {
	"bump_left": Vector2.LEFT * bump_impulse,
	"bump_right": Vector2.RIGHT * bump_impulse,
	"bump_up": Vector2.UP * bump_impulse,
	"bump_down": Vector2.DOWN * bump_impulse,
}

func _physics_process(delta: float) -> void:
	# Handle bumps.
	for action in bump_impulses:
		if Input.is_action_just_pressed(action):
			apply_central_impulse(bump_impulses[action])
	# Handle drag.
	if Input.is_action_pressed("drag"):
		apply_force(linear_velocity * drag_factor)
