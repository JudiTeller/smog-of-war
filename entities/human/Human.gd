extends Node2D
class_name Human

var maxhealth = 100
var health = 100
var maxsuff = 10
var suffocation = 10


# Called when the node enters the scene tree for the first time.
func _ready():
    $Healthtick.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _input( event: InputEvent, ) -> void:
    pass
    

func _on_healthtick_timeout():
    pass # Replace with function body.
