extends Node2D

class_name HumanFactory

@export var startpoint: Node2D
@export var target: Node2D

var maxcap = 10
var startpoint_arr: Array[Vector2]
var nav_arr: Array[NavigationPolygon]

@onready var human_node: Node2D = $humans
@onready var human = preload("res://entities/human/human.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $human_cycle.start()
    pass # Replace with function body.


# Triggers all functions for a cycle update
func human_routine() -> void:
    # check if enough humans are present spawn new ones if necessary
    if human_node.get_child_count() < maxcap:
        spawn_humans(maxcap - human_node.get_child_count())
    pass

func spawn_humans(amount: int):
    # spawn in humans if a valid spawn and target location are set
    # this can be changed later to not require a target location for spawn
    if startpoint != null && target != null:
        var new_human = human.instantiate()
        new_human.position = startpoint_arr[randi_range(0, startpoint_arr.size() - 1)]
        human_node.add_child(new_human)
        calc_random_target_position()
        new_human._set_target(target)

    else:
        push_error("Either start or target location not set for human!")


func register_nav_area(new_area: NavigationPolygon):
    nav_arr.append(new_area)

func calc_random_target_position(): 
    for nav_area in nav_arr:
        var area_vertices: PackedVector2Array = nav_area.get_vertices()
        var poly_area_arr: Array[PackedInt32Array] = []
        for i in nav_area.get_polygon_count():
            poly_area_arr.append(nav_area.get_polygon(i))
            print(i)
        for single_poly in poly_area_arr:

            var single_area = calc_poly_area(area_vertices[single_poly[0]], area_vertices[single_poly[1]], area_vertices[single_poly[2]])
    pass
    
func calc_poly_area(a: Vector2, b: Vector2, c: Vector2):
    return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + b.x * (a.y - b.y)) / 2)

func set_maxcap(newcap: int) -> void:
    maxcap = newcap

func set_startpoint_arr(arr: Array[Vector2]):
    startpoint_arr = arr

