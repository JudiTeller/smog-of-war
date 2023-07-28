extends Node2D

class_name BuildingManager

@onready var worldGen: WorldGenerator = get_parent().get_parent().get_node("World")
@onready var tileMap = worldGen.getTileMap()

@onready var resMan: ResourceManager = get_parent().get_node("ResourceManager")

var buildings = []
var selected_building = null

func global_to_map(pos) -> Vector2i:
    var map_pos = tileMap.local_to_map(tileMap.to_local(pos))
    return Vector2i(map_pos.x, map_pos.y)

func map_to_global(pos) -> Vector2:
    return tileMap.to_global(tileMap.map_to_local(Vector2(pos.x, pos.y)))

func canPlace(pos: Vector2i, new_building: Building):
    return worldGen.isTileEmpty(global_to_map(pos)) # TODO: add size check

func placeBuilding(pos, new_building: Building, repaired:bool, skipTint: bool = false, skipCheck:bool = false):
    if !skipCheck and (!canPlace(pos, new_building) or !resMan.spendIfPossible(new_building.get_building_cost())):
        return false 

    var tile_pos = global_to_map(pos)
    pos = map_to_global(tile_pos)
    new_building.set_building_position(pos, tile_pos)
    if repaired:
        new_building.repair()
    new_building.place_building()
    worldGen.place_building_at_tile(new_building, skipTint)
    buildings.append(new_building)
    return true

func demolishBuilding(building: Building):
    if !building.can_be_demolished():
        return false
    buildings.erase(building)
    worldGen.remove_building_at_tile(building)
    resMan.addHumans(building.get_refund())
    return true

func getBuildingAtTile(tileCords: Vector2i):
    var found_building = null
    for building in buildings:
        if building.get_tile_cords() == tileCords:
            if found_building != null: # Should never happen
                push_error("Multiple buildings at same tile") 
                return null
            found_building = building
    return found_building

func getBuildingAtGlobal(pos: Vector2):
    return getBuildingAtTile(global_to_map(pos))

func getTileMap():
    return tileMap

func getWorldGen():
    return worldGen
