extends Area2D

class_name Click_Area

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _on_timer_timeout():
    call_deferred("queue_free")
