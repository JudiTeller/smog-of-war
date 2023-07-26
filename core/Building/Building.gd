extends Node2D

class_name Building

@export var BrokenSprite: Sprite2D
@export var RepairedSprite: Sprite2D
@export var Name: String
@export var Description: String
@export var Cost: int
@export var Repaired: bool = false
@export var Size: Vector2 = Vector2(128, 128)

var placed: bool = false

func _ready():
    set_process_input(true)
    set_process(true)

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index != MOUSE_BUTTON_LEFT \
            or !event.pressed or !placed:
            return
        emit_signal("building_selected", self)

func repair():
    Repaired = true
    BrokenSprite.set_visible(false)
    RepairedSprite.set_visible(true)

func damage():
    Repaired = false
    BrokenSprite.set_visible(true)
    RepairedSprite.set_visible(false)

func set_building_position(pos):
    set_position(pos)

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