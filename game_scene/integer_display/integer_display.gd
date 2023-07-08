extends HBoxContainer

## The name of the PlayerData property to show in this display.
@export
var property: String

## How long it takes to reach the final displayed value.
@export_range(0.0, 10.0, 0.1)
var ramp_time := 0.0

## The underlying display.
@onready
var _display := $ScoreboardDisplay

## The last displayed value.
var _last_displayed := 0

## The progress, in time, towards the current value.
var _progress := 0.0

## The displayed value before the most recent change.
var _before_last_change := 0

func _ready() -> void:
	var value: int = PlayerData.get(property)
	_last_displayed = value
	_before_last_change = value
	_display.score = value
	PlayerData.connect(property + "_changed", _on_change)

func _on_change(new_value: int) -> void:
	if ramp_time:
		_before_last_change = _last_displayed
		_progress = 0.0
	else:
		_display.score = new_value

func _process(delta: float) -> void:
	if ramp_time:
		_progress = minf(_progress + delta, ramp_time)
		var value: int = PlayerData.get(property)
		_last_displayed = int(lerpf(_before_last_change, value, _progress / ramp_time))
		_display.score = _last_displayed
