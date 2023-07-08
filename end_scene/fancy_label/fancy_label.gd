class_name FancyLabel
extends Label

## Whether the label has a fancy rainbow animation.
var fancy: bool:
	get:
		return $gradient.visible
	set(value):
		if value:
			$gradient.visible = true
			clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		else:
			$gradient.visible = false
			clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
