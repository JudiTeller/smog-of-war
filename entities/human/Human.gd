extends CharacterBody2D
class_name Human

@onready var root: Node2D = get_parent()
var target: Vector2
var current_nav_target: Vector2
var navigation_arr: PackedVector2Array
var navigation_counter: int = 0
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var tilemap: TileMap
var nav_astar: AStar2D

var speed = 300
var acceleration = 7
var region_index: int

var maxhealth = 100
var health = 100
var maxsuff = 10
var suffocation = 10


# Called when the node enters the scene tree for the first time.
func _ready():
    $Healthtick.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


func _physics_process( delta: float, ) -> void:
    # checks if human has reached target or navigation node
    if is_near_target():
        _set_target(get_random_target_position())

    if is_near_nav_location():
        advance_nav_path()

    # always walks to next navigation node
    var direction = global_position.direction_to(tilemap.to_global(tilemap.map_to_local(current_nav_target)))
    global_position += direction * delta * speed

func _set_target(new_target: Vector2):
    target = new_target
    if nav_astar == null:
        astar_setup()

    calculate_nav_path()
    advance_nav_path()

    pass


func get_random_target_position() -> Vector2:
    var random_index: int = randi_range(0, Pathfinding.walkable_nodes_regions[region_index].size() - 1)
    var random_target = Pathfinding.walkable_nodes_regions[region_index][random_index]

    return random_target


func astar_setup():
    # fuck all this shit right here
    nav_astar = AStar2D.new()
    var walkable_region := Pathfinding.walkable_nodes_regions[region_index]
    # add all points to AStar instance
    for i in range(walkable_region.size()):
        nav_astar.add_point(i, walkable_region[i])

    # create all valid connections
    for i in range(walkable_region.size() - 1):
        var surrounding_tiles := tilemap.get_surrounding_cells(walkable_region[i])
        var connection_counter := 0
        for j in range(i + 1, walkable_region.size()):
            var possible_connection := walkable_region[j] as Vector2i
            if possible_connection in surrounding_tiles:
                connection_counter += 1
                nav_astar.connect_points(i, j, true)
                if connection_counter == 4:
                    break


func calculate_nav_path():
    var position_tilebased = tilemap.local_to_map(tilemap.to_local(position))
    var walkable_region := Pathfinding.walkable_nodes_regions[region_index]
    var start_id = walkable_region.find(position_tilebased)
    var target_id = walkable_region.find(target)

    if start_id != -1 && target_id != -1:
        navigation_arr = nav_astar.get_point_path(start_id, target_id)

    else:
        push_error("couldn't calculate path, invalid position ids")


func advance_nav_path():
    if navigation_arr.size() > 0:
        current_nav_target = navigation_arr[0]
        navigation_arr.remove_at(0)


func is_near_target() -> bool:
    var global_target = tilemap.to_global(tilemap.map_to_local(target))
    return position.distance_to(global_target) < 10.0


func is_near_nav_location() -> bool:
    var global_nav_step = tilemap.to_global(tilemap.map_to_local(current_nav_target))
    return position.distance_to(global_nav_step) < 10.0


func set_region_index(ind: int):
    region_index = ind


func set_tilemap(map: TileMap):
    tilemap = map



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
