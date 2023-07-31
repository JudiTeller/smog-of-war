extends Node2D

class_name ResourceManager

@export_category("Humans")
@export var humans = 0
@export_category("Air Quality")
@export var startAirQuality = randi_range(0, 50) / 100.0
@export var airQuality = startAirQuality

@export_category("Misc")
@export var click_area_size: int = 1

@export_category("Cheats")
@export var InfinitePeople = false

signal WorldCleaned()

func _input(event):
    if event.is_action_pressed("key_z"):
        humans += 1
    if event.is_action_pressed("key_h"):
        humans -= 1
    if event.is_action_pressed("key_u"):
        print("People: ", humans)

func addHumans(amount):
    if amount < 0:
        push_error("addHumans called with negative amount (", amount, ")")
        return

    humans += amount

    # checking for overflow
    if humans < 0:
        print("Too many humans! Activating Infinite People cheat.") # TODO: Switch to big numbers to prevent overflows
        InfinitePeople = true
        humans = 0

func onHumanCured(_human: Human):
    addHumans(1)

func canAfford(amount):
    return InfinitePeople or humans >= amount

func spendIfPossible(amount):
    if InfinitePeople:
        return true

    if canAfford(amount):
        humans -= amount
        return true
    return false

func isCityClean():
    return is_equal_approx(airQuality, 1.0)

func increaseAirQuality(amount):
    if amount < 0:
        push_error("increaseAirQuality called with negative amount (", amount, ")")
        return
    if amount > 1.0:
        push_error("increaseAirQuality called with amount > 1.0 (", amount, ")")
        return

    airQuality += amount
    if airQuality > 1.0:
        airQuality = 1.0

    if isCityClean():
        print("clean!")
        emit_signal("WorldCleaned")
        get_tree().change_scene_to_file("res://Scenes/game/end/game_end.tscn")

func getHumans():
    return humans

func getAirQuality():
    return airQuality

func on_score_signal(value: float):
    airQuality += value / 20000