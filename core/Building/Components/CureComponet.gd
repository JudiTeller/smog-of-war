extends Area2D

class_name CureComponent

@export var Active: bool = true
@export var Radius: float = 100.0
@export var CureRate: float = 1 # 1 cure per second
@export var CureAmount: float = 1 # 1 People per Tick
@export var CureEffectiveness: float = 0.5 # 50% of the people are cured
@export var TickRate = 1.0 # every 1 second the cure is applied
@export var Upgrades: Array = [
    {
        "Radius": 20.0,
        "CureRate": 0.2,
        "CureAmount": 1,
        "CureEffectiveness": 0.7,
        "TickRate": 0.0,
    },{
        "Radius": 20.0,
        "CureRate": 0.2,
        "CureAmount": 1,
        "CureEffectiveness": 0.7,
        "TickRate": 0.0,
    },{
        "Radius": 20.0,
        "CureRate": 0.2,
        "CureAmount": 1,
        "CureEffectiveness": 0.7,
        "TickRate": 0.0,
    },{
        "Radius": 20.0,
        "CureRate": 0.2,
        "CureAmount": 1,
        "CureEffectiveness": 0.7,
        "TickRate": 0.0,
    },{
        "Radius": 20.0,
        "CureRate": 0.2,
        "CureAmount": 1,
        "CureEffectiveness": 0.7,
        "TickRate": 0.0,
    },
]

@onready var TickTimer:Timer = $Timer

var humansInRange = []

func _ready():
    TickTimer.wait_time = TickRate
    TickTimer.one_shot = false
    if Active:
        TickTimer.start()
    
    print(get_parent().get_name() + " ready ", Radius)
    $CollisionShape2D.shape.radius = Radius

func _on_Area2D_body_entered(body):
    if !body.is_in_group("Human"):
        return
    humansInRange.append(body as Human)

func _on_Area2D_body_exited(body):
    if !body.is_in_group("Human"):
        return
    humansInRange.erase(body as Human)

func _tick():
    if !Active:
        return

    var cured = 0
    for human in humansInRange:
        if randf() < CureEffectiveness:
            human.cure(CureRate)
        cured += 1

        if cured >= CureAmount:
            break

func activate():
    Active = true
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    TickTimer.start()

func deactivate():
    Active = false
    TickTimer.stop()

func getUpgradeCost(level:int):
    return Upgrades[level]["Cost"]

func getUpgradeMaxLevel():
    return Upgrades.size()

func upgrade(level:int):
    if level >= Upgrades.size():
        print("Upgrade level is too high")
        return

    Radius += Upgrades[level]["Radius"]
    CureRate += Upgrades[level]["CureRate"]
    CureAmount += Upgrades[level]["CureAmount"]
    CureEffectiveness += Upgrades[level]["CureEffectiveness"]
    TickRate += Upgrades[level]["TickRate"]

    applyNewValues()

func applyNewValues():
    $CollisionShape2D.shape.radius = max(Radius, 1)
    TickTimer.wait_time = max(TickRate, 0.1)

    CureRate = max(CureRate, 0.1)
    CureAmount = max(CureAmount, 1)
    CureEffectiveness = clamp(CureEffectiveness, 0.0, 1.0)
