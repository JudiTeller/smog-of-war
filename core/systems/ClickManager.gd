extends Node2D

@onready var buMan: BuildingManager = get_parent().get_node("BuildingManager")
@onready var resMan: ResourceManager = get_parent().get_node("ResourceManager")
@onready var hover_sprite: Sprite2D = $HoverSprite

enum Action {
    CLICK,
    PLACE
}

var selectedBuilding: Building = null
var currentAction: Action = Action.CLICK

func _process(_delta):
    if selectedBuilding == null:
        return
    if hover_sprite.texture != null:
        hover_sprite.set_visible(true)
        var spritePos = buMan.map_to_global(buMan.global_to_map(get_global_mouse_position()))
        spritePos -= buMan.getWorldGen().getOffsetForBuildingSprite(hover_sprite, selectedBuilding.get_sprite_offset())
        hover_sprite.set_global_position(spritePos)
        if buMan.canPlace(get_global_mouse_position(), selectedBuilding) \
            and resMan.canAfford(selectedBuilding.get_building_cost()):
            hover_sprite.set_modulate(Color(0, 1, 0, 0.8))
        else:
            hover_sprite.set_modulate(Color(1, 0, 0, 0.8))

func _input(event):
    match currentAction:
        Action.CLICK:
            if event is InputEventMouseButton:
                handleClickMouseInput(event)
            elif event is InputEventKey:
                handleClickKeyInput(event)
        Action.PLACE:
            if event is InputEventMouseButton:
                handlePlaceMouseInput(event)
            elif event is InputEventKey:
                handlePlaceKeyInput(event)

func handleClickMouseInput(event):
    if !event.pressed:
        return

    if event.button_index == MOUSE_BUTTON_RIGHT:
        var mousePos = get_global_mouse_position()
        var building = buMan.getBuildingAtGlobal(mousePos)
        if building != null:
            # If the clicked building is already selected, unselect it
            if selectedBuilding == building:
                selectedBuilding.toggleSelection()
                selectedBuilding = null
            # If the clicked building is not already selected, select it
            else:
                # If there is already a selected building, unselect it
                if selectedBuilding != null:
                    selectedBuilding.toggleSelection()
                selectedBuilding = building
                selectedBuilding.toggleSelection()
        print("Clicked on: ", building)
    elif event.button_index == MOUSE_BUTTON_LEFT:
        pass # TODO: Clicker for Humans

func handleClickKeyInput(event: InputEventKey):
    if !event.pressed:
        return
    if event.as_text_keycode() == "Delete":
        if selectedBuilding != null and buMan.demolishBuilding(selectedBuilding):
            cleanSelectedBuilding(false)
        else:
            print("Could not demolish building")
    if event.as_text_keycode() == "1":
        if selectedBuilding != null:
            selectedBuilding.toggleSelection()
        var new_building = preload("res://entities/buildings/Placeable/hospital.tscn").instantiate()
        selectedBuilding = new_building
        hover_sprite.set_texture(selectedBuilding.getTexture(true).duplicate())
        currentAction = Action.PLACE

func handlePlaceMouseInput(event):
    if !event.pressed or selectedBuilding == null or event.button_index != MOUSE_BUTTON_LEFT:
        return
    var mousePos = get_global_mouse_position()
    if buMan.placeBuilding(mousePos, selectedBuilding, true):
        cleanSelectedBuilding(false)
        currentAction = Action.CLICK

func handlePlaceKeyInput(event: InputEventKey):
    if !event.pressed:
        return
    if event.as_text_keycode() == "Escape":
        cleanSelectedBuilding(true)
        currentAction = Action.CLICK

func cleanSelectedBuilding(free_building: bool):
    if selectedBuilding == null:
        return
    hover_sprite.set_texture(null)
    hover_sprite.set_visible(false)
    if free_building and selectedBuilding != null:
        selectedBuilding.queue_free()
    selectedBuilding = null
