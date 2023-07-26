extends Node2D

class_name BuildingManager

@onready var worldGen: WorldGenerator = get_parent().get_parent().get_node("World")
@onready var tileMap = worldGen.getTileMap()

var buildings = []
var selected_building = null

func canPlace(pos, building):
    return true # TODO: check if building can be placed

func placeBuilding(pos, building: Building):
    if !canPlace(pos, building):
        return false
    var tile_pos = tileMap.local_to_map(pos)
    building.set_building_position(tile_pos)
    building.place_building()
    
    worldGen.place_building_at_tile(tile_pos, building, true)
    buildings.append(building)
    return true
