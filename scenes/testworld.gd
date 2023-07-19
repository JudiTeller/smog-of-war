extends Node2D

var skyscraper1 = preload("res://entities/buildings/skyscraper1/skyscraper1.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(0, 320, 32):
        for j in range(0, 320, 32):
            var building_to_add = skyscraper1.instantiate()
            
            var timer: Timer = building_to_add.get_child(1)
            timer.wait_time = randf_range(0.5, 1)
            
            building_to_add.position.y = i
            building_to_add.position.x = j
            add_child(building_to_add)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
