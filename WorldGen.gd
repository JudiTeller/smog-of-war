extends Node2D

@export var WORLD_SIZE:int = 200
@export var SEED: int = randi()

@export var BUILDINGS: Array[PackedScene]
@export var BUILDING_OFFSET = 24
@export var TINT = Color(0.0, 0.0, 0.2, 1.0)

@onready var Buildings = $Buildings
@onready var WorldTileMap = $WorldTileMap

const target_tile_id = 1
var randomGen = RandomNumberGenerator.new()
var noodleNoise

func _ready():
    randomGen.seed = SEED

    var noise = FastNoiseLite.new()
    noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
    noise.set_seed(SEED)
    noise.set_frequency(0.2)
    noise.set_fractal_octaves(3)
    noise.set_fractal_gain(0.1)
    noise.set_fractal_lacunarity(0.1)

    # Wait for the noise to be generated
    var noiseTexture = NoiseTexture2D.new()
    noiseTexture.noise = noise
    noiseTexture.width = WORLD_SIZE
    noiseTexture.height = WORLD_SIZE
    await noiseTexture.changed
    
    var gridNoise = Image.create(WORLD_SIZE, WORLD_SIZE, false, Image.FORMAT_RGBA8)
    
    for x in range(WORLD_SIZE):
        for y in range(WORLD_SIZE):
            if !(x % 2 != 0 and y % 2 != 0):
                gridNoise.set_pixel(x, y, Color.BLACK)
            else:
                gridNoise.set_pixel(x, y, Color.WHITE)

    var noiseImg = noiseTexture.get_image()

    for x in range(WORLD_SIZE):
        for y in range(WORLD_SIZE):
            var value = noiseImg.get_pixel(x, y).r
            if value > 0.8:
                gridNoise.set_pixel(x, y, Color.WHITE) # House
            else:
                gridNoise.set_pixel(x, y, Color.BLACK) # Nothing
        
    # dilate the noise
    for _x in 2:
        var copyImg = gridNoise.duplicate()
        for x in range(WORLD_SIZE):
            for y in range(WORLD_SIZE):
                if copyImg.get_pixel(x, y).r == 1.0:
                    gridNoise.set_pixel(x - 1, y, Color.WHITE)
                    gridNoise.set_pixel(x + 1, y, Color.WHITE)
                    gridNoise.set_pixel(x, y - 1, Color.WHITE)
                    gridNoise.set_pixel(x, y + 1, Color.WHITE)
    
    var copyImg = gridNoise.duplicate()
    for x in range(WORLD_SIZE):
        for y in range(WORLD_SIZE):
            if copyImg.get_pixel(x, y).r == 1.0:
                if copyImg.get_pixel(x - 1, y).r != 1.0:
                    gridNoise.set_pixel(x - 1, y, Color.WEB_GRAY)
                if copyImg.get_pixel(x + 1, y).r != 1.0:
                    gridNoise.set_pixel(x + 1, y, Color.WEB_GRAY)
                if copyImg.get_pixel(x, y - 1).r != 1.0:
                    gridNoise.set_pixel(x, y - 1, Color.WEB_GRAY)
                if copyImg.get_pixel(x, y + 1).r != 1.0:
                    gridNoise.set_pixel(x, y + 1, Color.WEB_GRAY)
                # Digonal
                if copyImg.get_pixel(x - 1, y - 1).r != 1.0:
                    gridNoise.set_pixel(x - 1, y - 1, Color.WEB_GRAY)
                if copyImg.get_pixel(x + 1, y - 1).r != 1.0:
                    gridNoise.set_pixel(x + 1, y - 1, Color.WEB_GRAY)
                if copyImg.get_pixel(x - 1, y + 1).r != 1.0:
                    gridNoise.set_pixel(x - 1, y + 1, Color.WEB_GRAY)
                if copyImg.get_pixel(x + 1, y + 1).r != 1.0:
                    gridNoise.set_pixel(x + 1, y + 1, Color.WEB_GRAY)
    

    # gets all gray images on the border and saves them in a metadata
    var border = []
    for x in range(WORLD_SIZE):
        if abs(gridNoise.get_pixel(x, 0).r - 0.5) < 0.1:
            border.append(Vector2(x, 0))
        if abs(gridNoise.get_pixel(x, WORLD_SIZE - 1).r - 0.5) < 0.1:
            border.append(Vector2(x, WORLD_SIZE - 1))
        if abs(gridNoise.get_pixel(0, x).r - 0.5) < 0.1:
            border.append(Vector2(0, x))
        if abs(gridNoise.get_pixel(WORLD_SIZE - 1, x).r - 0.5) < 0.1:
            border.append(Vector2(WORLD_SIZE - 1, x))
    
    print("streets_on_border: " + str(border.size()))
    set_meta("streets_on_border", border)

    noodleNoise = gridNoise
    # display noise
    $Noise.texture = ImageTexture.create_from_image(noodleNoise)

    generate_tiles()

func generate_tiles():
    var size = WORLD_SIZE/2
    var streets = []

    for x in range(-size, size):
        for y in range(-size, size):
            if noodleNoise.get_pixel(x + size, y + size).r == 1.0:
                place_building_at_tile(Vector2(x, y))
                WorldTileMap.set_cell(1, Vector2(x, y), 0, Vector2(3, 3))
            elif noodleNoise.get_pixel(x + size, y + size).r > 0.0:
                streets.append(Vector2(x, y))
            else:
                WorldTileMap.set_cell(0, Vector2(x, y), 1, Vector2(0, 0))
                
    WorldTileMap.set_cells_terrain_connect(0, streets, 0, 0)

func place_building_at_tile(tileCords):
    var random_choice = BUILDINGS[randomGen.randi_range(0, BUILDINGS.size() - 1)]
    var building = random_choice.instantiate()
    var sprite = building.get_node("Sprite2D")

    # random tint of base_color for the sprite
    var colorOff = randomGen.randf()
    var tintColor = TINT + Color(colorOff, colorOff, colorOff, 0.0)
    sprite.modulate = tintColor

    sprite.position = WorldTileMap.to_global(WorldTileMap.map_to_local(tileCords))
    sprite.position.y -= sprite.texture.get_height() / 2 - BUILDING_OFFSET

    Buildings.add_child(building)
