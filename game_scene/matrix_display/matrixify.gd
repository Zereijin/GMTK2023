extends MeshInstance2D

@export
var matrix_pixel_size:Vector2 = Vector2(6.0, 6.0)

@export
var palette_size:float = 4.0

@export
var color:Color = Color(0.89, 0.953, 0, 1.0)

@export
var border_scale:float = 0.01

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	self.material.set_shader_parameter("matrix_pixel_size", self.matrix_pixel_size)
	self.material.set_shader_parameter("palette_size", self.palette_size)
	self.material.set_shader_parameter("color", self.color)
	self.material.set_shader_parameter("border_scale", self.border_scale)
	
