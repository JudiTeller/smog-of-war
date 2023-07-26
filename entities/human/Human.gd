extends CharacterBody2D
class_name Human

@onready var root: Node2D = get_parent()
@onready var target = root.find_child("target")
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var speed = 300
var acceleration = 7

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

func _physics_process( delta: float, ) -> void:

    var next_location = nav.get_next_path_position()
    var direction = global_position.direction_to(next_location)
    global_position += direction * delta * speed

func _set_target(new_target: Node2D):
    target = new_target
    nav.target_position = target.position


func _input( event: InputEvent, ) -> void:
    pass


func _on_healthtick_timeout():
    pass # Replace with function body.


func _on_navigation_agent_2d_target_reached():
    get_parent().remove_child(self)
    queue_free()
    pass # Replace with function body.


func get_nav_agent() -> NavigationAgent2D:
    return nav
