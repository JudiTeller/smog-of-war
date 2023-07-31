extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func on_new_district_clicked():
    get_tree().change_scene_to_file("res://Scenes/main.tscn")
    pass


func on_exit_clicked():
    get_tree().quit()
    pass