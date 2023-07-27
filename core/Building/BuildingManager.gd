extends Node2D

class_name BuildingManager

@onready var worldGen: WorldGenerator = get_parent().get_parent().get_node("World")
@onready var tileMap = worldGen.getTileMap()

var buildings = []
var selected_building = null

func global_to_map(pos) -> Vector2i:
    var map_pos = tileMap.local_to_map(tileMap.to_local(pos))
    return Vector2i(map_pos.x, map_pos.y)

func map_to_global(pos) -> Vector2:
    return tileMap.to_global(tileMap.map_to_local(Vector2(pos.x, pos.y)))

func canPlace(pos: Vector2i, building: Building):
    return worldGen.isTileEmpty(global_to_map(pos)) # TODO: add size check

func placeBuilding(pos, building: Building):
    if !canPlace(pos, building):
        return false
    var tile_pos = global_to_map(pos)
    building.set_building_position(tile_pos)
    building.repair()
    building.place_building()
    worldGen.place_building_at_tile(tile_pos, building, false, building.get_sprite_offset())
    buildings.append(building)
    return true

func getTileMap():
    return tileMap

func getWorldGen():
    return worldGen
