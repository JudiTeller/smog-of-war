extends Node2D

class_name WorldGenerator

@export_group("World")
@export var WORLD_SIZE:int = 200
@export var BUILDINGS: Array[PackedScene]
@export var BUILDING_TINT = Color(0.0, 0.0, 0.2, 1.0)

@export_group("Generation Settings")
@export var SEED: int = randi()
@export var FREQUENCY: float = 0.2
@export var OCTAVES: int = 3
@export var GAIN: float = 0.1
@export var LACUNARITY: float = 0.1
@export var DILATE_AMOUNT = 2
@export var CONNECTION_ROADS_SAMPLE_RATE = 5

@export_group("Debug")
@export var SHOW_NOISE: bool = false

@onready var Buildings = $Buildings
@onready var WorldTileMap = $WorldTileMap

const BUILDING_DEFAULT_OFFSET = 24
var randomGen = RandomNumberGenerator.new()
var noodleNoise

# Function to initialize noise parameters
func _ready():
    print("Generating world with seed: " + str(SEED))
    var base_noise = await setup_noise(SEED, FREQUENCY, OCTAVES, GAIN, LACUNARITY)
    generate_and_dilate_noise(base_noise)

    if SHOW_NOISE:
        $Noise.texture = ImageTexture.create_from_image(noodleNoise)
    generate_tiles()

# Function to setup noise parameters
func setup_noise(noise_seed, frequency, octaves, noise_gain, lacunarity) -> Image:
    randomGen.seed = noise_seed

    var noise = FastNoiseLite.new()
    noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
    noise.set_seed(noise_seed)
    noise.set_frequency(frequency)
    noise.set_fractal_octaves(octaves)
    noise.set_fractal_gain(noise_gain)
    noise.set_fractal_lacunarity(lacunarity)
    
    # Generate noise texture
    var noiseTexture = NoiseTexture2D.new()
    noiseTexture.noise = noise
    noiseTexture.width = WORLD_SIZE
    noiseTexture.height = WORLD_SIZE
    await noiseTexture.changed

    return noiseTexture.get_image()

# Function to generate and dilate noise
func generate_and_dilate_noise(base_noise):
    var image = create_grid_noise()
    apply_noise_to_grid(base_noise, image)
    dilate(image, Color.WHITE, DILATE_AMOUNT)
    dilate(image, Color.WEB_GRAY, 1, Color.WHITE, true)
    add_connection_streets(image)
    var borderStreets = get_streets_on_border(image)

    print("streets_on_border: " + str(borderStreets.size()))
    set_meta("streets_on_border", borderStreets)

    noodleNoise = image

func isStreet(value) -> bool:
    return abs(value - 0.5) < 0.1

func isNothing(value) -> bool:
    return abs(value - 0.0) < 0.1

func isHouse(value) -> bool:
    return abs(value - 1.0) < 0.1

# Function to add connection streets
func add_connection_streets(image):
    var sampleRate = CONNECTION_ROADS_SAMPLE_RATE

    var copyImg = image.duplicate()
    for x in range(0, WORLD_SIZE, sampleRate):
        for y in range(0, WORLD_SIZE, sampleRate):
            var pixel = copyImg.get_pixel(x, y).r
            var nextStreet = null
            # check if street and right neighbor is not street
            if (x == 0 and y != 0) or (isStreet(pixel) and isNothing(copyImg.get_pixel(x + 1, y).r)):
                image.set_pixel(x, y, Color.WEB_GRAY)
                # get next street in x direction
                nextStreet = null
                for i in range(x + 1, WORLD_SIZE):
                    if isStreet(copyImg.get_pixel(i, y).r):
                        nextStreet = Vector2(i, y)
                if nextStreet != null:
                    # place street tiles between only if there is Color.BLACK
                    for i in range(x + 1, nextStreet.x):
                        if copyImg.get_pixel(i, y) == Color.BLACK:
                            image.set_pixel(i, y, Color.WEB_GRAY)

            # Same for bottom neighbor in y direction
            if (y == 0 and x != 0) or (isStreet(pixel) and isNothing(copyImg.get_pixel(x, y + 1).r)):
                image.set_pixel(x, y, Color.WEB_GRAY)
                nextStreet = null
                for i in range(y + 1, WORLD_SIZE):
                    if isStreet(copyImg.get_pixel(x, i).r):
                        nextStreet = Vector2(x, i)
                if nextStreet != null:
                    for i in range(y + 1, nextStreet.y):
                        if copyImg.get_pixel(x, i) == Color.BLACK:
                            image.set_pixel(x, i, Color.WEB_GRAY)

            

# Function to create grid noise
func create_grid_noise() -> Image:
    var image = Image.create(WORLD_SIZE, WORLD_SIZE, false, Image.FORMAT_RGBA8)
    
    for x in range(WORLD_SIZE):
        for y in range(WORLD_SIZE):
            if x % 2 != 0 and y % 2 != 0:
                image.set_pixel(x, y, Color.WHITE) # House
            else:
                image.set_pixel(x, y, Color.BLACK) # Nothing
    return image

# Function to apply noise to the grid
func apply_noise_to_grid(noiseImg, image):
    for x in range(WORLD_SIZE):
        for y in range(WORLD_SIZE):
            var value = noiseImg.get_pixel(x, y).r
            if value > 0.8:
                image.set_pixel(x, y, Color.WHITE) # House
            else:
                image.set_pixel(x, y, Color.BLACK) # Nothing

# Function to dilate the noise
func dilate(image, target_color: Color, iterations=1, check_color=null, check_diagonals=false):
    for _i in range(iterations):
        var copyImg = image.duplicate()
        for x in range(WORLD_SIZE):
            for y in range(WORLD_SIZE):
                if getPixel(copyImg, x, y) != Color.WHITE:
                    continue
                if check_color == null or getPixel(copyImg, x - 1, y) != check_color:
                    setPixel(image, x - 1, y, target_color)
                if check_color == null or getPixel(copyImg, x + 1, y) != check_color:
                    setPixel(image, x + 1, y, target_color)
                if check_color == null or getPixel(copyImg, x, y - 1) != check_color:
                    setPixel(image, x, y - 1, target_color)
                if check_color == null or getPixel(copyImg, x, y + 1) != check_color:
                    setPixel(image, x, y + 1, target_color)

                # Diagonals
                if !check_diagonals:
                    continue
                if check_color == null or getPixel(copyImg, x - 1, y - 1) != check_color:
                    setPixel(image, x - 1, y - 1, target_color)
                if check_color == null or getPixel(copyImg, x + 1, y - 1) != check_color:
                    setPixel(image, x + 1, y - 1, target_color)
                if check_color == null or getPixel(copyImg, x - 1, y + 1) != check_color:
                    setPixel(image, x - 1, y + 1, target_color)
                if check_color == null or getPixel(copyImg, x + 1, y + 1) != check_color:
                    setPixel(image, x + 1, y + 1, target_color)

func setPixel(image, x, y, color):
    if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
        return
    image.set_pixel(x, y, color)

func getPixel(image, x, y):
    if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
        return Color.BLACK
    return image.get_pixel(x, y)

# Function to get target_color on the borderStreets
func get_streets_on_border(image):
    var borderStreets = []
    for x in range(WORLD_SIZE):
        if abs(image.get_pixel(x, 0).r - 0.5) < 0.1:
            borderStreets.append(Vector2(x, 0))
        if abs(image.get_pixel(x, WORLD_SIZE - 1).r - 0.5) < 0.1:
            borderStreets.append(Vector2(x, WORLD_SIZE - 1))
        if abs(image.get_pixel(0, x).r - 0.5) < 0.1:
            borderStreets.append(Vector2(0, x))
        if abs(image.get_pixel(WORLD_SIZE - 1, x).r - 0.5) < 0.1:
            borderStreets.append(Vector2(WORLD_SIZE - 1, x))
    return borderStreets

# Function to generate tiles
func generate_tiles():
    var size = WORLD_SIZE/2.0
    var streets = []

    # size to int, if size needs to be floored +1
    var upper = size
    if size - int(size) > 0.0:
        upper += 1
    for x in range(-size, upper):
        for y in range(-size, upper):
            var pixel = noodleNoise.get_pixel(x + size, y + size).r
            if pixel == 1.0: # House
                var random_choice: Node2D = BUILDINGS[randomGen.randi_range(0, BUILDINGS.size() - 1)].instantiate()
                place_building_at_tile(Vector2(x, y), random_choice, false, Vector2.ZERO)
            elif pixel > 0.0: # Street
                streets.append(Vector2(x, y))
            else: # Nothing
                WorldTileMap.set_cell(0, Vector2(x, y), 1, Vector2(0, 0))
                
    WorldTileMap.set_cells_terrain_connect(0, streets, 0, 0)

# Function to place building at tile
func place_building_at_tile(tileCords: Vector2, new_building: Node2D, skipTint: bool = false, offset: Vector2 = Vector2.ZERO, spriteName = "Broken"):
    var sprite = new_building.get_node(spriteName)

    # random tint of base_color for the sprite
    if !skipTint:
        var colorOff = randomGen.randf()
        var tintColor = BUILDING_TINT + Color(colorOff, colorOff, colorOff, 0.0)
        sprite.modulate = tintColor

    new_building.position = WorldTileMap.to_global(WorldTileMap.map_to_local(tileCords))
    new_building.position.y -= sprite.texture.get_height() / 2 - offset.y - BUILDING_DEFAULT_OFFSET
    new_building.z_index = int(tileCords.y) + int((WORLD_SIZE/2.0)) # Formula = y_pos + the half of the world size to start at 0
    # Foundation
    WorldTileMap.set_cell(0, tileCords, 2, Vector2(0, 0))
    Buildings.add_child(new_building)

func isTileEmpty(tileCords: Vector2i) -> bool:
    # check if tile exists
    var cells = WorldTileMap.get_used_cells(0)
    var index = cells.find(tileCords)
    if index == -1:
        return false
    var found_tile_pos = cells[index]
    # Source ID 1 = Nothing / Empty Land
    return WorldTileMap.get_cell_source_id(0, found_tile_pos) == 1

func getTileMap():
    return WorldTileMap

func getOffsetForBuildingSprite(sprite: Sprite2D, buildingOffset: Vector2) -> Vector2:
    return Vector2(
        buildingOffset.x,
        sprite.texture.get_height() / 2.0 - buildingOffset.y - BUILDING_DEFAULT_OFFSET
    )
