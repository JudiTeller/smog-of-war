extends Node2D

class_name RessourceManager

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

func canAfford(amount):
    return InfinitePeople or humans >= amount

func spendIfPossible(amount):
    if InfinitePeople:
        return true

    if canAfford:
        humans -= amount
        return true
    return false

func getHumans():
    return humans