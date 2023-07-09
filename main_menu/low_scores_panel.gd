class_name LowScoresPanel
extends Panel

## Emitted when the user closes the panel.
signal closed()

## Displays the low scores panel.
func go() -> void:
	# Populate the score labels.
	var scores := PlayerData.read_lowest_scores()
	for i in range(scores.size()):
		var node: Label = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer.get_node("score" + str(i))
		node.text = str(scores[i])

	# Display the panel.
	visible = true

	# Set focus.
	$MarginContainer/VBoxContainer/HBoxContainer/CloseButton.grab_focus()

func _close() -> void:
	visible = false
	closed.emit()

func _clear_and_close() -> void:
	DirAccess.remove_absolute("user://scores.ini")
	_close()
