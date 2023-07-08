extends Node

## Whether the music should be playing in the current scene.
var play: bool:
	get:
		return $music.playing
	set(value):
		if value != $music.playing:
			if value:
				$music.play()
			else:
				$music.stop()
