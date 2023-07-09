extends Control

@export var start_scene: PackedScene

func _ready():
	get_tree().paused = false
	randomize()
	$MainMenuButtonContainer/PlayButton.grab_focus()
	Music.play = false

func _on_play_button_pressed():
	var error := get_tree().change_scene_to_packed(start_scene)
	if error != OK:
		print(error)
		get_tree().quit(1)

func _on_credits_button_pressed():
	$CreditPanel.visible=true
	$CreditPanel/MarginContainer/VBoxContainer/CloseCreditsButton.grab_focus()

func _on_close_credits_button_pressed():
	$CreditPanel.visible=false
	$MainMenuButtonContainer/CreditsButton.grab_focus()

func _on_controls_button_pressed():
	$ControlsPanel.visible=true
	$ControlsPanel/MarginContainer/VBoxContainer/CloseControlsButton.grab_focus()

func _on_close_controls_button_pressed():
	$ControlsPanel.visible=false
	$MainMenuButtonContainer/ControlsButton.grab_focus()

func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
