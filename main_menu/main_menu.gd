extends Control

@export var start_scene: PackedScene
var mainMenuFocusButton : Button

func _ready():
	randomize()
	mainMenuFocusButton = $MainMenuButtonContainer/PlayButton
	mainMenuFocusButton.grab_focus()

func _on_play_button_pressed():
	var error := get_tree().change_scene_to_packed(start_scene)
	if error != OK:
		print(error)
		get_tree().quit(1)

func _on_credits_button_pressed():
	mainMenuFocusButton = $MainMenuButtonContainer/CreditsButton
	get_node("CreditPanel").visible=true
	$CreditPanel/MarginContainer/VBoxContainer/CloseCreditsButton.grab_focus()

func _on_close_credits_button_pressed():
	get_node("CreditPanel").visible=false
	mainMenuFocusButton.grab_focus()

func _on_controls_button_pressed():
	mainMenuFocusButton = $MainMenuButtonContainer/ControlsButton
	get_node("ControlsPanel").visible=true
	$ControlsPanel/MarginContainer/VBoxContainer/CloseControlsButton.grab_focus()

func _on_close_controls_button_pressed():
	get_node("ControlsPanel").visible=false
	mainMenuFocusButton.grab_focus()

func _on_quit_button_pressed():
	get_tree().quit()
