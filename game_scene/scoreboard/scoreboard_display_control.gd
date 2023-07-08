class_name ScoreboardDisplayControl

extends Label

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

# extra spaces to add so that it doesn't wrap loop
var scroll_padding = 2

func _set_score(new_score):
	score = new_score
	raw_text = str(score)
	update_text()

func _set_animation_speed( new_animation_speed ):
	animation_speed = new_animation_speed
	animation_timer.set_wait_time(new_animation_speed)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_characters_max() -> int:
	# Since we're looking at a monospaced font we can easily calculate number of
	# chars we can allow on the display
	return int(
		self.size.x / float(
			theme.default_font.get_string_size("0", HORIZONTAL_ALIGNMENT_RIGHT, -1, theme.default_font_size).x
		)
	)

func _on_animation_timer():
	if animation == AnimationTypes.SCROLL:
		# Then move the offset and pull out the text to rotate
		scroll_offset = ( scroll_offset + 1 ) % get_characters_max()
		update_text()

func update_text():
	# Find out what the maximum length of the display (which can also
	# be the max length of the text
	var max_length = get_characters_max()

	# SCROLL: scrolls the around around the display
	if animation == AnimationTypes.SCROLL:
		# If the number of characters is less than the number of display chars
		# let's just left pad with spaces. If we are the same length or beyond
		# we'll just pad with extra spaces
		var base_string = ""
		var required_padding = max_length - len(raw_text)
		if required_padding > scroll_padding:
			base_string = " ".repeat(required_padding) + raw_text
		else:
			base_string = raw_text + " ".repeat(scroll_padding)

		# Then move the offset and pull out the text to rotate
		var scrolled_text = base_string.repeat(2).substr(scroll_offset, max_length)

		self.text = scrolled_text

	# None: no special animation required
	else:
		self.text = raw_text.substr(0, max_length)



