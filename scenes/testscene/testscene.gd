extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
    var startpoints: Array[Vector2] = []
    for node in $startpoint.get_children():
        startpoints.append(node.global_position)

    $human_factory.set_startpoint_arr(startpoints)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
