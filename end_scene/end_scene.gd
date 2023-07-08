class_name EndScene
extends CenterContainer

func go(scores: PackedInt64Array, my_score_pos: int) -> void:
	for i in range(scores.size()):
		var text := str(scores[i])
		if i == my_score_pos:
			text += " <<<"
		$VBoxContainer/scores.get_node("score" + str(i)).text = text
	visible = true

func _try_again() -> void:
	get_tree().change_scene_to_file("res://game_scene/game_scene.tscn")

func _main_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _exit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
