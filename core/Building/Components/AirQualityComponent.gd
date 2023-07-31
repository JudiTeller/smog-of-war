extends Node2D

class_name AirQualityComponent

@export var Active: bool = true
@export var CleaniseAmount: float = 0.005 # 0.5% of the air is cleaned per tick
@export var Delta: float = 0.005 # Randomness of the CleaniseAmount
@export var TickRate = 1.0 # every 1 second the air is cleaned
@export var Upgrades: Array = [
    {
        "CleaniseAmount": 0.003,
        "Delta": -0.002,
        "TickRate": 0.0
    },{
        "CleaniseAmount": 0.003,
        "Delta": -0.002,
        "TickRate": 0.0
    },{
        "CleaniseAmount": 0.003,
        "Delta": -0.002,
        "TickRate": 0.0
    },{
        "CleaniseAmount": 0.003,
        "Delta": -0.002,
        "TickRate": 0.0
    },{
        "CleaniseAmount": 0.003,
        "Delta": -0.002,
        "TickRate": 0.0
    },
]

@onready var resMan: ResourceManager = get_parent().get_parent().get_parent().get_parent().get_node("Systems/ResourceManager")
@onready var TickTimer:Timer = $Timer

func _ready():
    TickTimer.wait_time = TickRate
    TickTimer.one_shot = false
    if Active:
        TickTimer.start()

func _tick():
    if !Active:
        return

    var amount = CleaniseAmount + randf_range(-Delta, Delta)
    if amount < 0:
        print("CleaniseAmount - Delta is less than 0")
        return
    resMan.increaseAirQuality(CleaniseAmount + amount)

func activate():
    Active = true
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    TickTimer.start()

func deactivate():
    Active = false
    TickTimer.stop()

func getUpgradeMaxLevel():
    return Upgrades.size()

func upgrade(level:int):
    if level >= Upgrades.size():
        print("Upgrade level is too high")
        return

    CleaniseAmount += Upgrades[level]["CleaniseAmount"]
    Delta += Upgrades[level]["Delta"]
    TickRate += Upgrades[level]["TickRate"]

    applyNewValues()

func applyNewValues():
    TickTimer.wait_time = TickRate
