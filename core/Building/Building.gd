extends Node2D

class_name Building

@export var Sprites: AnimatedSprite2D
@export var SpriteOffset: Vector2 = Vector2.ZERO
@export var Name: String
@export var Description: String
@export var Cost: int
@export var Repaired: bool = false
@export var Size: Vector2 = Vector2(128, 128)

var placed: bool = false

func _ready():
    set_process_input(true)
    set_process(true)

    if not Repaired:
        Sprites.play("broken")
    else:
        Sprites.play("repaired")

func repair():
    Repaired = true
    Sprites.play("repaired")

func damage():
    Repaired = false
    Sprites.play("broken")

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

func get_sprite_offset():
    return SpriteOffset

func getTexture(repaired = null):
    var animation_name = ""
    if repaired == null:
        animation_name = Sprites.animation
    elif repaired:
        animation_name = "repaired"
    else:
        animation_name = "broken"
    return Sprites.sprite_frames.get_frame_texture(animation_name, Sprites.frame)
