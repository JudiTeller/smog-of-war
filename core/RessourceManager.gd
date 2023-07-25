extends Node2D

class_name RessourceManager

var people = 0

func _input(event):
    if event.is_action_pressed("key_z"):
        people += 1
    if event.is_action_pressed("key_h"):
        people -= 1
    if event.is_action_pressed("key_u"):
        print("People: ", people)

func canAfford(amount):
    return people >= amount

func spendIfPossible(amount):
    if people >= amount:
        people -= amount
        return true
    return false

func getPeople():
    return people