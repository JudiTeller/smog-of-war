extends Node2D

@export var WORLD_SIZE:int = 200
@export var SEED: int = randi()

@export var BUILDINGS = ["res://assets/buildings/skyscraper/skyscraper1new.png"]
@export var BUILDING_OFFSET = 24
@export var TINT = Color(0.0, 0.0, 0.2, 1.0)

@onready var Buildings = $Buildings
@onready var WorldTileMap = $WorldTileMap

const target_tile_id = 1
var randomGen = RandomNumberGenerator.new()

func _ready():
    randomGen.seed = SEED

    generate_tiles()

func generate_tiles():
    var size = WORLD_SIZE/2
    for x in range(-size, size):
        for y in range(-size, size):
            var tile_id = randomGen.randi_range(0, 1)
            WorldTileMap.set_cell(0, Vector2(x, y), 0, Vector2(tile_id, 0)) # TODO: Change later to autotile
            if tile_id == target_tile_id:
                place_building_at_tile(Vector2(x,y))

func place_building_at_tile(tileCords):
    var sprite = Sprite2D.new()
    var random_choice = BUILDINGS[randomGen.randi_range(0, BUILDINGS.size() - 1)]
    sprite.texture = load(random_choice)

    # random tint of base_color for the sprite
    var colorOff = randomGen.randf()
    var tintColor = TINT + Color(colorOff, colorOff, colorOff, 0.0)
    sprite.modulate = tintColor

    sprite.position = WorldTileMap.to_global(WorldTileMap.map_to_local(tileCords))
    sprite.position.y -= sprite.texture.get_height() / 2 - BUILDING_OFFSET

    Buildings.add_child(sprite)
