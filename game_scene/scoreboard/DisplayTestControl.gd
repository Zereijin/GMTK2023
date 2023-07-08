extends Control

@onready
var display = %ScoreboardDisplay

# Used to access the enum for AnimationTypes
const ScoreboardControl = preload("res://game_scene/scoreboard/scoreboard_display_control.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_text_edit_text_changed():
	display.raw_text = %EditScore.text

func _on_scroll_enable_toggled(button_pressed):
	if button_pressed:
		display.animation = ScoreboardControl.AnimationTypes.SCROLL
	else:
		display.animation = ScoreboardControl.AnimationTypes.NONE

func _on_increment_score_pressed():
	display.score += 1000

func _on_scroll_speed_value_changed(value):
	display.animation_speed = value
