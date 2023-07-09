extends Control

@export var start_scene: PackedScene

func _ready():
	# Do general setup.
	get_tree().paused = false
	randomize()
	$MainMenuButtonContainer/PlayButton.grab_focus()
	Music.play = false

	# Load the volume settings from the config file into the bus.
	var settings := ConfigFile.new()
	settings.load("user://settings.ini")
	for bus in range(AudioServer.bus_count):
		var volume = settings.get_value("Volume", AudioServer.get_bus_name(bus))
		if volume is float and volume <= 0:
			AudioServer.set_bus_volume_db(bus, volume)

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

func _on_sound_button_pressed() -> void:
	$SoundPanel.go()

func _on_sound_panel_closed() -> void:
	$MainMenuButtonContainer/SoundButton.grab_focus()

func _on_low_scores_button_pressed() -> void:
	$LowScoresPanel.go()

func _on_low_scores_panel_closed() -> void:
	$MainMenuButtonContainer/LowScoresButton.grab_focus()

func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
