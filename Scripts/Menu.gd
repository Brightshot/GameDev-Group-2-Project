extends Control

@export var next_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_packed(next_scene)


func _on_about_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/About.tscn")
