extends Node2D

@onready var buMan: BuildingManager = get_parent().get_node("BuildingManager")
@onready var resMan: RessourceManager = get_parent().get_node("RessourceManager")
@onready var hover_sprite: Sprite2D = $HoverSprite

enum Action {
    CLICK,
    PLACE,
    DESTORY
}

var selectedBuilding: Building = null
var currentAction: Action = Action.CLICK

func _process(_delta):
    if selectedBuilding != null and !selectedBuilding.isPlaced():
        hover_sprite.set_visible(true)
        var spritePos = buMan.map_to_global(buMan.global_to_map(get_global_mouse_position()))
        spritePos -= buMan.getWorldGen().getOffsetForBuildingSprite(hover_sprite, selectedBuilding.get_sprite_offset())
        hover_sprite.set_global_position(spritePos)
        if buMan.canPlace(get_global_mouse_position(), selectedBuilding) \
            and resMan.canAfford(selectedBuilding.get_building_cost()):
            hover_sprite.set_modulate(Color(0, 1, 0))
        else:
            hover_sprite.set_modulate(Color(1, 0, 0))

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
        Action.DESTORY:
            if event is InputEventMouseButton:
                handleDestoryMouseInput(event)
            elif event is InputEventKey:
                handleDestoryKeyInput(event)

func handleClickMouseInput(event):
    pass

func handleClickKeyInput(event: InputEventKey):
    if !event.pressed:
        return
    assert (selectedBuilding == null)
    if event.as_text_keycode() == "1":
        var new_building = preload("res://entities/buildings/Placeable/hospital.tscn").instantiate()
        selectedBuilding = new_building
        hover_sprite.set_texture(selectedBuilding.get_node("Repaired").get_texture().duplicate())
        currentAction = Action.PLACE

func handlePlaceMouseInput(event):
    if !event.pressed or selectedBuilding == null or event.button_index != MOUSE_BUTTON_LEFT:
        return
    var mousePos = get_global_mouse_position()
    if buMan.canPlace(mousePos, selectedBuilding):
        if resMan.spendIfPossible(selectedBuilding.get_building_cost()):
            buMan.placeBuilding(mousePos, selectedBuilding)
            cleanSelectedBuilding(true)
            currentAction = Action.CLICK
        else:
            print("Not enough ressources")
    else:
        print("Can't place here")

func handlePlaceKeyInput(event: InputEventKey):
    if !event.pressed:
        return
    if event.as_text_keycode() == "Escape":
        cleanSelectedBuilding(false)
        currentAction = Action.CLICK

func handleDestoryMouseInput(event):
    pass

func handleDestoryKeyInput(event):
    pass

func cleanSelectedBuilding(placed: bool):
    if selectedBuilding == null:
        return

    hover_sprite.set_texture(null)
    hover_sprite.set_visible(false)
    if !placed:
        selectedBuilding.queue_free()
    selectedBuilding = null
