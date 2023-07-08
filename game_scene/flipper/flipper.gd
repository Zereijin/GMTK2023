extends Node2D

## The minimum amount of time after the ball enters the trigger area before the flipper fires.
@export_range(0.0, 1.0, 0.01)
var delay_minimum := 0.0

## The maximum amount of time after the ball enters the trigger area before the flipper fires.
@export_range(0.0, 1.0, 0.01)
var delay_maximum := 0.5

## Whether a pre-fire delay is currently active.
var _prefiring := false

## Whether the trigger is currently in the active position.
var _active := false

## The trigger area.
@onready
var _trigger := $trigger

## The animation player.
@onready
var _player := $AnimationPlayer

func _physics_process(delta: float) -> void:
	if not _prefiring and not _player.is_playing():
		if _trigger.has_overlapping_bodies():
			_prefiring = true
			await get_tree().create_timer(randf_range(delay_minimum, delay_maximum), false).timeout
			_prefiring = false
			_player.play("fire")
			_active = true
		elif _active:
			_player.play("release")
			_active = false
