extends Node2D

class_name ResourceManager

@export var humans = 0

@export_category("Cheats")
@export var InfinitePeople = false

func _input(event):
    if event.is_action_pressed("key_z"):
        humans += 1
    if event.is_action_pressed("key_h"):
        humans -= 1
    if event.is_action_pressed("key_u"):
        print("People: ", humans)

func addHumans(amount):
    if amount < 0:
        push_error("addHumans called with negative amount")
        return

    humans += amount

    # checking for overflow
    if humans < 0:
        print("Too many humans! Activating Infinite People cheat.") # TODO: Switch to big numbers to prevent overflows
        InfinitePeople = true
        humans = 0

func canAfford(amount):
    return InfinitePeople or humans >= amount

func spendIfPossible(amount):
    if InfinitePeople:
        return true

    if canAfford(amount):
        humans -= amount
        return true
    return false

func getHumans():
    return humans