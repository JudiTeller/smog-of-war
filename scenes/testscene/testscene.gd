extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
    # when level is loaded in, get positions of all defined startlocations
    # this routine needs to be implemented by the actual level script
    var startpoints: Array[Vector2] = []
    
    for node in $startpoint.get_children():
        startpoints.append(node.global_position)

    # provide start positions to the human factory
    $human_factory.set_startpoint_arr(startpoints)
    
    $human_factory.set_navigation_map($TileMap.get_navigation_map(0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
