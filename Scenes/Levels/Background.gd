extends TextureRect

@export_category("Present")
@export var camera : Node2D
@export var offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = camera.global_position + offset
