class_name SoundPanel
extends Panel

## Emitted when the sound panel is dismissed.
signal closed()

## Initializes the sliders and displays the panel.
func go() -> void:
	# Set the volume sliders in the sound control panel to match the bus.
	for bus in range(AudioServer.bus_count):
		var slider := $MarginContainer/VBoxContainer/GridContainer \
			.get_node(AudioServer.get_bus_name(bus) + "Slider") as HSlider
		if slider != null:
			slider.set_value_no_signal(_linear_to_perceptual(_decibel_to_linear( \
				AudioServer.get_bus_volume_db(bus))))

	# Show the panel.
	visible = true

	# Move focus to the first slider.
	$MarginContainer/VBoxContainer/GridContainer/MasterSlider.grab_focus()

func _on_close_button_pressed():
	# Hide the panel.
	visible = false

	# Save the volume settings to the config file.
	var settings := ConfigFile.new()
	settings.load("user://settings.ini")
	for bus in range(AudioServer.bus_count):
		var bus_name := AudioServer.get_bus_name(bus)
		var slider := $MarginContainer/VBoxContainer/GridContainer \
			.get_node(bus_name + "Slider") as HSlider
		if slider != null:
			settings.set_value("Volume", bus_name, AudioServer.get_bus_volume_db(bus))
	settings.save("user://settings.ini")

	# Notify the parent.
	closed.emit()

func _on_volume_slider_value_changed(value: float, bus: String) -> void:
	var db := _linear_to_decibel(_perceptual_to_linear(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)
	var preview := $PreviewSounds.get_node(bus) as AudioStreamPlayer
	if preview != null:
		preview.play()

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
