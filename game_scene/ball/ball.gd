class_name Ball
extends RigidBody2D

## The drag state machine.
enum DragState {
	## Drag is inactive and, conditional on fuel availability, can be activated immediately.
	IDLE,
	## Drag is active.
	ACTIVE,
	## Drag was used and cannot be used until the cooldown expires.
	COOLING_DOWN,
	## Drag was used and cannot be used until the cooldown expires. The drag button was pushed near
	## the end of the cooldown period, so once cooldown finishes, drag will activate again
	## immediately.
	COOLING_DOWN_QUEUED,
}

## The magnitude of impulse to apply each time the bump action is activated. Should be positive.
## Higher means more bump.
@export
var bump_impulse := 200.0

## The scaling factor from velocity to applied force when drag mode is activated. Should be
## negative. Larger magnitude means more drag.
@export
var drag_factor := -10.0

## How long after ending a drag the player must wait before starting the next drag.
@export_range(0.0, 60.0, 0.01)
var drag_cooldown := 1.0

## How long before the end of the drag cooldown period the player can re-press the drag key and have
## the drag start at the end of the cooldown.
@export_range(0.0, 60.0, 0.01)
var drag_cooldown_buffer_time := 0.5

## Whether the ball currently permits player control inputs.
var sensitive := true

## The current drag state.
var _drag_state := DragState.IDLE

## How long remains until drag can next be activated.
##
## This variable is only relevant in the COOLING_DOWN and COOLING_DOWN_QUEUED states.
var _drag_cooldown_remaining := 0.0

## A mapping from bump action names to directional impulse vectors.
@onready
var _bump_impulses := {
	"bump_left": Vector2.LEFT * bump_impulse,
	"bump_right": Vector2.RIGHT * bump_impulse,
	"bump_up": Vector2.UP * bump_impulse / 2,
	"bump_down": Vector2.DOWN * bump_impulse,
}

func _physics_process(delta: float) -> void:
	if sensitive:
		# Handle bumps.
		for action in _bump_impulses:
			if Input.is_action_just_pressed(action):
				if PlayerData.use_bump():
					apply_central_impulse(_bump_impulses[action])

					$smokeGPUParticles2D.process_material.direction = -Vector3(_bump_impulses[action].x, _bump_impulses[action].y, 0.0)
					# Call restart() to emit new particle.
					# Otherwise, setting `emitting` to true during a particle cycle has no effect.
					$smokeGPUParticles2D.restart()

					$nudgeAudioStreamPlayer2D.play()

		# Handle drag.
		match (_drag_state):
			DragState.IDLE:
				if Input.is_action_just_pressed("drag"):
					if PlayerData.use_drag(delta):
						_drag_state = DragState.ACTIVE
			DragState.ACTIVE:
				if not Input.is_action_pressed("drag") or not PlayerData.use_drag(delta):
					_drag_state = DragState.COOLING_DOWN
					_drag_cooldown_remaining = drag_cooldown
			DragState.COOLING_DOWN, DragState.COOLING_DOWN_QUEUED:
				if Input.is_action_just_pressed("drag") and _drag_cooldown_remaining < drag_cooldown_buffer_time:
					_drag_state = DragState.COOLING_DOWN_QUEUED
				_drag_cooldown_remaining -= delta
				if _drag_cooldown_remaining <= 0:
					if _drag_state == DragState.COOLING_DOWN_QUEUED and PlayerData.use_drag(delta):
						_drag_state = DragState.ACTIVE
					else:
						_drag_state = DragState.IDLE
		if _drag_state == DragState.ACTIVE:
			apply_force(linear_velocity * drag_factor)

	else:
		_drag_state = DragState.IDLE

	if _drag_state == DragState.ACTIVE:
		$dragGPUParticles2D.emitting = true
		if not $dragAudioStreamPlayer2D.is_playing():
			$dragAudioStreamPlayer2D.play()
	else:
		$dragGPUParticles2D.emitting = false
		if $dragAudioStreamPlayer2D.is_playing():
			$dragAudioStreamPlayer2D.stop()

	if _drag_state == DragState.COOLING_DOWN:
		if not $cooldownGPUParticles2D.emitting:
			$cooldownGPUParticles2D.emitting = true
	else:
		if $cooldownGPUParticles2D.emitting:
			$cooldownGPUParticles2D.emitting = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ball_collision_notifiable"):
		body.ball_contact(self)


func _on_visibility_changed():
	if visible == false:
		# Remove all smoke and drag particles.
		# Otherwise, they also become invisible but freeze in time.
		# They then become visible again when the ball reappears.
		# Particles are removed by first restarting emit, and then immediately setting emitting to false
		$smokeGPUParticles2D.restart()
		$smokeGPUParticles2D.emitting = false

		$dragGPUParticles2D.restart()
		$dragGPUParticles2D.emitting = false

		$cooldownGPUParticles2D.restart()
		$cooldownGPUParticles2D.emitting = false
