class_name IntegerDisplay
extends PanelContainer

## The name of the PlayerData property to show in this display.
@export
var property: String

## How long it takes to reach the final displayed value.
@export_range(0.0, 10.0, 0.1)
var ramp_time := 0.0

## The underlying display.
@onready
var _display: ScoreboardDisplayControl = $MarginContainer/ScoreboardDisplay

## The last displayed value.
var _last_displayed := 0

## The progress, in time, towards the current value.
var _progress := 0.0

## The displayed value before the most recent change.
var _before_last_change := 0

## The queue of messages waiting to be displayed.
var _message_queue := PackedStringArray()

## The position of the next message to display in _message_queue.
var _message_queue_next := 0

## Enqueues a message to be shown on this display.
##
## The message will be shown immediately if the integer is currently visible. Otherwise, the message
## will be shown after any previously requested messages have finished.
func enqueue_message(message: String) -> void:
	if _display.animation == ScoreboardDisplayControl.AnimationTypes.NONE:
		# The integer is currently being shown. The message need not be queued. Show it now.
		_display.animation = ScoreboardDisplayControl.AnimationTypes.SCROLL
		_display.raw_text = message
	else:
		# Some other textual message is being shown. Queue up this message.
		_message_queue.append(message)

## Displays a message immediately, replacing any current message and dropping any queued messages.
func override_message(message: String) -> void:
	_message_queue.clear()
	_message_queue_next = 0
	_display.animation = ScoreboardDisplayControl.AnimationTypes.SCROLL
	_display.raw_text = message

func _ready() -> void:
	var value: int = PlayerData.get(property)
	_last_displayed = value
	_before_last_change = value
	_display.raw_text = str(value)
	PlayerData.connect(property + "_changed", _on_change)

func _on_change(new_value: int) -> void:
	if ramp_time:
		_before_last_change = _last_displayed
		_progress = 0.0
	elif _display.animation == ScoreboardDisplayControl.AnimationTypes.NONE:
		# No animated message is being shown, so we can show the score now.
		_display.raw_text = str(new_value)

func _process(delta: float) -> void:
	if ramp_time:
		_progress = minf(_progress + delta, ramp_time)
		var value: int = PlayerData.get(property)
		_last_displayed = int(lerpf(_before_last_change, value, _progress / ramp_time))
		if _display.animation == ScoreboardDisplayControl.AnimationTypes.NONE:
			# No animated message is being shown, so we can show the score now.
			_display.raw_text = str(_last_displayed)

func _on_scoreboard_display_scrolled() -> void:
	if _message_queue_next == _message_queue.size():
		# There are no more messages.
		_message_queue.clear()
		_message_queue_next = 0
		_display.raw_text = str(_last_displayed)
		_display.animation = ScoreboardDisplayControl.AnimationTypes.NONE
	else:
		# There is another message.
		_display.raw_text = _message_queue[_message_queue_next]
		_message_queue_next += 1
