class_name PauseMenu
extends Control

## Displays the pause menu.
func go() -> void:
	visible = true
	$buttons/resume.grab_focus()

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("pause"):
			accept_event()
			_resume()

func _resume() -> void:
	visible = false
	get_tree().paused = false

func _open_sound_panel() -> void:
	$sound_panel.go()

func _sound_panel_closed() -> void:
	$buttons/sound.grab_focus()

func _restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game_scene/game_scene.tscn")

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
