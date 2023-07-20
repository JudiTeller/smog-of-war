extends TileMap

var target_tile_id = 1
var cell_size = Vector2(128, 128)

@export var WORLD_SIZE:int = 25
@export var BUILDINGS = ["res://assets/buildings/skyscraper/skyscraper1new.png"]
@export var OFFSET = 24

func _ready():
    randomize()  # initialize the random seed
    generate_tiles()

func generate_tiles():
    var size = round(WORLD_SIZE/2)
    for x in range(-size, size):
        for y in range(-size, size):
            var tile_id = randi() % 2
            print(tile_id)
            set_cell(0, Vector2(x, y), 0, Vector2(tile_id, 0)) # TODO: Change later to autotile
            if tile_id == target_tile_id:
                place_building_at_tile(Vector2(x,y))

func place_building_at_tile(tileCords):
    var sprite = Sprite2D.new()
    var random_choice = BUILDINGS[randi() % BUILDINGS.size()]
    sprite.texture = load(random_choice)
    sprite.position = to_global(map_to_local(tileCords))
    sprite.position.y -= sprite.texture.get_height() / 2 - OFFSET # TODO: Check why the offset
    var buildings_node = %Buildings
    buildings_node.call_deferred("add_child", sprite)

