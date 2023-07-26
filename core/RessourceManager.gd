extends Node2D

class_name RessourceManager

@export var people = 0

@export_category("Cheats")
@export var InfinitePeople = false

func _input(event):
    if event.is_action_pressed("key_z"):
        people += 1
    if event.is_action_pressed("key_h"):
        people -= 1
    if event.is_action_pressed("key_u"):
        print("People: ", people)

func canAfford(amount):
    return InfinitePeople or people >= amount

func spendIfPossible(amount):
    if InfinitePeople:
        return true

    if canAfford:
        people -= amount
        return true
    return false

func getPeople():
    return people