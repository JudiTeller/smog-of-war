extends CharacterBody2D
class_name Human

@export_group("Health")
@export var health = 100
@export var maxhealth = 100
@export var maxsuff = 10
@export var suffocation = randi_range(5, maxsuff)

@export_group("Movement")
@export var acceleration = 7
@export var speed = 300

@export_group("Navigation")
@export var region_index: int

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var ruMan: ResourceManager = get_parent().get_parent().get_parent().get_parent().get_node("Systems/ResourceManager")

var current_nav_target: Vector2
var navigation_arr: PackedVector2Array
var navigation_counter: int = 0
var nav_astar: AStar2D
var target: Vector2
var tilemap: TileMap
var waitAfterTargetReached: bool = false

signal HumanCured(human: Human)
signal HumanDied(human: Human)

# Called when the node enters the scene tree for the first time.
func _ready():
    $Healthtick.start()
    $AnimatedSprite2D.play()
    connect("HumanCured", ruMan.onHumanCured)

func _physics_process( delta: float, ) -> void:
    # checks if human has reached target or navigation node
    if is_near_target() and !waitAfterTargetReached:
        _set_target(get_random_target_position())

    if is_near_nav_location():
        advance_nav_path()

    if is_near_target() and waitAfterTargetReached:
        # Skip Movement if he is waiting at the target
        return
    # always walks to next navigation node
    var direction = global_position.direction_to(tilemap.to_global(tilemap.map_to_local(current_nav_target)))
    global_position += direction * delta * speed

    if direction.x < 0:
        $AnimatedSprite2D.animation = "walk_left"
    else:
        $AnimatedSprite2D.animation = "walk_right"


func _set_target(new_target: Vector2):
    target = new_target
    if nav_astar == null:
        astar_setup()

    calculate_nav_path()
    advance_nav_path()

    pass

func setWaitAfterTargetReached(wait: bool):
    waitAfterTargetReached = wait

func get_nearest_Points(pos: Vector2, amount=1) -> Array[Vector2]:
    # Get amount nearest points to pos
    var walkable_region := Pathfinding.walkable_nodes_regions[region_index]
    var points:Array[Vector2] = []
    var distances = []

    for i in range(walkable_region.size()):
        var point = walkable_region[i]
        var distance = pos.distance_to(point)
        distances.append(distance)
        points.append(point)

    if amount > points.size():
        amount = points.size()

    var sorted = distances.duplicate()
    sorted.sort()
    var result:Array[Vector2] = []
    for i in range(amount):
        var index = distances.find(sorted[i])
        result.append(points[index])

    return result

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


func _on_healthtick_timeout():
    health -= suffocation

    if health <= 0:
        onDeath()


func get_nav_agent() -> NavigationAgent2D:
    return nav

func isCured() -> bool:
    return suffocation <= 0

func cure(amount: int):
    if amount < 0:
        push_error("cure amount must be positive")
        return

    suffocation -= amount

    if isCured():
        onDeath()

func onDeath():
    if isCured():
        emit_signal("HumanCured", self)
    else:
        emit_signal("HumanDied", self)

    get_parent().remove_child(self)
    self.queue_free()
