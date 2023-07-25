extends Node2D

class_name BuildingManager

var buildings = []
var selected_building = null

func canPlace(pos, building):
    return true # TODO: check if building can be placed

func placeBuilding(pos, building: Building):
    if !canPlace(pos, building):
        return false
    
    building.set_building_position(pos)
    building.place_building()
    add_child(building)
    buildings.append(building)
    return true

func _on_Building_Selected(building):
    selected_building = building

func _on_Building_Deselected(building):
    selected_building = null

func _on_Building_Upgraded(building):
    pass
