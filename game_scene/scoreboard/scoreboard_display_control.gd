class_name ScoreboardDisplayControl

extends Label

## Emitted when the scrolling animation reaches the end and wraps around.
signal scrolled()

# Text to initially display in the display
@export
var raw_text: String = "0": set = _set_raw_text

enum AnimationTypes {
	# Default state where we don't do strange things with the display
	NONE,

	# We'll scroll the display of text
	SCROLL
}

@export
var animation:AnimationTypes = AnimationTypes.NONE: set = _set_animation

# Speed of the individual character increments for scroll rotation
@export
var animation_speed:float = 1.0: set = _set_animation_speed

@onready
var animation_timer = $AnimationTimer

@export
var score:int = 0: set = _set_score

# What character are we on with the scrolling?
var scroll_offset = 0

## The raw text, padded with spaces on both sides so it can be used for scrolling.
var _padded_text: String:
	get:
		var text := raw_text
		var width := get_characters_max()
		var padding : = " ".repeat(width)
		return padding + text + padding

func _set_score(new_score):
	score = new_score
	raw_text = str(score)
	update_text()

func _set_animation_speed( new_animation_speed ):
	animation_speed = new_animation_speed
	$AnimationTimer.set_wait_time(new_animation_speed)

func _set_raw_text( new_raw_text ):
	raw_text = new_raw_text
	update_text()

func _set_animation(new_animation):
	animation = new_animation
	if animation == AnimationTypes.SCROLL:
		scroll_offset = 0
		animation_timer.start()
	else:
		scroll_offset = 0
		animation_timer.stop()
		update_text()

# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	animation_timer.set_wait_time(animation_speed)

func get_characters_max() -> int:
	# Since we're looking at a monospaced font we can easily calculate number of
	# chars we can allow on the display
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")
	return int(
		self.size.x / float(
			font.get_string_size("0", HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size).x
		)
	)

func _on_animation_timer():
	if animation == AnimationTypes.SCROLL:
		# Then move the offset and pull out the text to rotate
		scroll_offset = ( scroll_offset + 1 ) % (raw_text.length() + get_characters_max())
		update_text()
		if scroll_offset == 0:
			scrolled.emit()

func update_text():
	# Find out what the maximum length of the display (which can also
	# be the max length of the text
	var max_length = get_characters_max()

	# SCROLL: scrolls the around around the display
	if animation == AnimationTypes.SCROLL:
		# Pull out the text to rotate
		self.text = _padded_text.substr(scroll_offset, max_length)
	# None: no special animation required
	else:
		self.text = raw_text.substr(0, max_length)
