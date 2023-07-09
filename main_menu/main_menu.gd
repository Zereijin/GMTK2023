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

	# Set the volume sliders in the sound control panel to match the bus.
	for bus in range(AudioServer.bus_count):
		var slider := $SoundPanel/MarginContainer/VBoxContainer/GridContainer \
			.get_node(AudioServer.get_bus_name(bus) + "Slider") as HSlider
		if slider != null:
			slider.set_value_no_signal(_linear_to_perceptual(_decibel_to_linear( \
				AudioServer.get_bus_volume_db(bus))))
		else:
			print("No slider for " + AudioServer.get_bus_name(bus))

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
	$SoundPanel.visible = true
	$SoundPanel/MarginContainer/VBoxContainer/GridContainer/MasterSlider.grab_focus()

func _on_close_sound_button_pressed():
	$SoundPanel.visible = false
	$MainMenuButtonContainer/SoundButton.grab_focus()

	# Save the volume settings to the config file.
	var settings := ConfigFile.new()
	settings.load("user://settings.ini")
	for bus in range(AudioServer.bus_count):
		var bus_name := AudioServer.get_bus_name(bus)
		var slider := $SoundPanel/MarginContainer/VBoxContainer/GridContainer \
			.get_node(bus_name + "Slider") as HSlider
		if slider != null:
			settings.set_value("Volume", bus_name, AudioServer.get_bus_volume_db(bus))
	settings.save("user://settings.ini")

func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_volume_slider_value_changed(value: float, bus: String) -> void:
	var db := _linear_to_decibel(_perceptual_to_linear(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)

## Converts a perceptual volume between 0 and 1 to a linear volume between 0 and 1.
func _perceptual_to_linear(value: float) -> float:
	# This formula was borrowed from PulseAudio.
	return value * value * value

## Converts a linear volume between 0 and 1 to a perceptual volume between 0 and 1.
func _linear_to_perceptual(value: float) -> float:
	return value ** (1.0 / 3.0)

## Converts a linear volume between 0 and 1 to a nonpositive decibel volume.
func _linear_to_decibel(value: float) -> float:
	# This formula was borrowed from PulseAudio.
	return 20 * log(value) / log(10)

## Converts a nonpositive decibel volume to a linear volume between 0 and 1.
func _decibel_to_linear(value: float) -> float:
	return 10 ** (value / 20)
