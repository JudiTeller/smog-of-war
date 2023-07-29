extends Node2D

class_name HumanFactory

@export var human_node: Node2D
@export var tilemap: TileMap
@export var maxcap = 10
@onready var human = preload("res://entities/human/human.tscn")

var startpoint_arr: Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if human_node == null:
        push_error("You forgot to select a human_node")

    call_deferred("setup")

func setup():
    set_startpoint_arr(Pathfinding.street_locations_border)

# Triggers all functions for a cycle update
func human_routine() -> void:
    # check if enough humans are present spawn new ones if necessary
    if human_node.get_child_count() < maxcap:
        spawn_humans(maxcap - human_node.get_child_count())

func spawn_humans(amount: int):
    # spawn in humans if a valid spawn and target location are set
    # this can be changed later to not require a target location for spawn

    if startpoint_arr.size() > 0:
        for i in range(amount):
            var random_index = randi_range(0, Pathfinding.street_locations_border.size() - 1)
            var random_spawn_vector = Pathfinding.street_locations_border[random_index]

            # calculate to offset position
            random_spawn_vector.x -= Pathfinding.worldsize / 2.0
            random_spawn_vector.y -= Pathfinding.worldsize / 2.0
            if !Pathfinding.spawn_locations_border.has(random_spawn_vector):
                print("Error: Spawn location not found in spawn_locations_border")
                return

            var new_human = human.instantiate()
            new_human.position = tilemap.to_global(tilemap.map_to_local(random_spawn_vector))
            new_human.set_tilemap(tilemap)
            new_human.set_region_index(Pathfinding.spawn_locations_border[random_spawn_vector])
            new_human._set_target(new_human.get_random_target_position())
            human_node.add_child(new_human)

    else:
        set_startpoint_arr(Pathfinding.street_locations_border)
        push_error("Spawn locations not set for human factory!")

func get_humans() -> Array[Human]:
    var humans: Array[Human] = []
    for i in range(human_node.get_child_count()):
        humans.append(human_node.get_child(i))
    return humans

func calc_poly_area(a: Vector2, b: Vector2, c: Vector2):
    return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + b.x * (a.y - b.y)) / 2)


func set_maxcap(newcap: int) -> void:
    maxcap = newcap


func set_startpoint_arr(arr: Array[Vector2]):
    startpoint_arr = arr


func register_tilemap(new_tilemap: TileMap):
    tilemap = new_tilemap

