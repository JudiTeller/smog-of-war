extends Node2D

class_name Building

@export_group("Visuals")
@export var Sprites: AnimatedSprite2D
@export var SpriteOffset: Vector2 = Vector2.ZERO

@export_group("Info")
@export var Name: String
@export var Description: String
@export var Cost: int

@export_group("State")
@export var Repaired: bool = false
@export var canBeDemolished: bool = true

@export_group("Misc")
@export var Size: Vector2 = Vector2(128, 128)
@export var RefundPercentage: float = 0.25
@export var selectionColor: Color = Color(1, 0, 0, 1)
@export var value: float

var tileCords: Vector2i = Vector2i.ZERO
var placed: bool = false
var selected: bool = false

func _ready():
    if not Repaired:
        Sprites.play("broken")
    else:
        Sprites.play("repaired")

func set_building_position(pos: Vector2, tilePos: Vector2i):
    set_position(pos)
    tileCords = tilePos

func repair():
    Repaired = true
    Sprites.play("repaired")

func damage():
    Repaired = false
    Sprites.play("broken")

func get_building_cost():
    return Cost

func get_building_name():
    return Name

func get_building_description():
    return Description

func is_building_repaired():
    return Repaired

func place_building():
    placed = true

func isPlaced():
    return placed

func get_sprite_offset():
    return SpriteOffset

func get_refund():
    return Cost * RefundPercentage

func can_be_demolished():
    return canBeDemolished

func getTexture(repaired = null):
    var animation_name = ""
    if repaired == null:
        animation_name = Sprites.animation
    elif repaired:
        animation_name = "repaired"
    else:
        animation_name = "broken"
    return Sprites.sprite_frames.get_frame_texture(animation_name, Sprites.frame)

func get_tile_cords():
    return tileCords

var oldModulate: Color
var oldZIndex: int
func toggleSelection():
    selected = !selected
    if selected:
        oldModulate = Sprites.modulate
        Sprites.modulate = selectionColor
        oldZIndex = get_z_index()
        set_z_index(999)
    else:
        var color = Color(1, 1, 1, 1)
        var newZIndex = 0
        if oldModulate != null:
            color = oldModulate
        Sprites.modulate = color

        if oldZIndex != null:
            newZIndex = oldZIndex
        set_z_index(newZIndex)

func is_selected():
    return selected

func _to_string() -> String:
    return Name + \
        "(Pos:" + str(get_tile_cords()) + \
        ", Placed:" + str(placed) + \
        ", Repaired:" + str(Repaired) + \
        ")"
