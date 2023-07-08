extends Node2D

## The message to show when the ball drains.
@export
var drain_message := "DRAIN"

## The message to show when the ball relaunches.
@export
var relaunch_message := "RELAUNCH"

## The message to show when the ball is captured by a kickout hole.
@export
var kickout_message := "KICKOUT"

## The message to show when an extra ball is earned.
@export
var extra_ball_message := "EXTRA BALL"

## The scoreboard.
@export
var scoreboard: IntegerDisplay

func _ready() -> void:
	get_tree().paused = false
	PlayerData.connect("extra_ball_earned", _on_extra_ball_earned)
	PlayerData.start_game()
	Music.play = true
	for hole in $holes.get_children():
		hole.connect("captured", _on_kickout_capture)

func _on_game_over() -> void:
	get_tree().paused = true
	var low_score_data := PlayerData.end_game()
	$hud/end_scene.go(low_score_data[0], low_score_data[1])

func _on_extra_ball_earned() -> void:
	scoreboard.enqueue_message(extra_ball_message)

func _on_drained() -> void:
	scoreboard.override_message(drain_message)

func _on_relaunched() -> void:
	scoreboard.enqueue_message(relaunch_message)

func _on_kickout_capture() -> void:
	scoreboard.enqueue_message(kickout_message)
