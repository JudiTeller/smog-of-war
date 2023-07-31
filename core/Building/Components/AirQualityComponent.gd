extends Area2D

@export var Active: bool = true
@export var CleaniseAmount: float = 0.005 # 0.5% of the air is cleaned per tick
@export var Delta: float = 0.005 # Randomness of the CleaniseAmount

@onready var resMan: ResourceManager = get_parent().get_parent().get_parent().get_parent().get_node("Systems/ResourceManager")
@onready var TickTimer:Timer = $Timer

func _ready():
    TickTimer.wait_time = 1.0
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
