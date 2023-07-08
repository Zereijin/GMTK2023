class_name EndScene
extends VBoxContainer

func go(scores: PackedInt64Array, my_score_pos: int) -> void:
	for i in range(scores.size()):
		var text := str(scores[i])
		if i == my_score_pos:
			text += " <<<"
		$VBoxContainer/scores.get_node("score" + str(i)).text = text
	visible = true

func _on_ok_button_pressed() -> void:
	print("OK pressed")
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
