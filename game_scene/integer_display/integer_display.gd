extends HBoxContainer

## The name of the PlayerData property to show in this display.
@export
var property: String

## The underlying display.
@onready
var _display := $ScoreboardDisplay

func _ready() -> void:
	_update_text(PlayerData.get(property))
	PlayerData.connect(property + "_changed", _update_text)

func _update_text(new_value: int) -> void:
	_display.score = new_value
