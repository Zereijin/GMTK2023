extends Node2D

func _on_game_over() -> void:
	get_tree().paused = true
	var low_score_data := PlayerData.end_game()
	$hud/end_scene.go(low_score_data[0], low_score_data[1])
