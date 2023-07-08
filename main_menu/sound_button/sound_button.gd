extends CheckBox

@onready var _master_audio_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	set_pressed_no_signal(not AudioServer.is_bus_mute(_master_audio_bus_index))

func _input(event):
	if event.is_action_pressed("ui_mute"):
		set_pressed(not is_pressed())

func _on_toggled(state):
	AudioServer.set_bus_mute(_master_audio_bus_index, state)
