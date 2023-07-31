extends Area2D

class_name AttractComponent

@export var Active: bool = true
@export var Radius: float = 100.0
@export var AttractEffectiveness: float = 0.5 # 50% of the people are attracted
@export var resistChance: float = 0.01 # 1% chance to resist after being attracted
@export var maxDistance: float = 400.0 # 10m max distance to target
@export var TickRate = 1.0 # every 1 second the people are checked for resist
@export var Upgrades: Array = [
    {
        "Radius": 20,
        "AttractEffectiveness": 0.1,
        "resistChance": 0.0,
        "maxDistance": 0.0,
        "TickRate": 0.0,
    },{
        "Radius": 20,
        "AttractEffectiveness": 0.1,
        "resistChance": 0.0,
        "maxDistance": 0.0,
        "TickRate": 0.0,
    },{
        "Radius": 20,
        "AttractEffectiveness": 0.1,
        "resistChance": 0.0,
        "maxDistance": 0.0,
        "TickRate": 0.0,
    },{
        "Radius": 20,
        "AttractEffectiveness": 0.1,
        "resistChance": 0.0,
        "maxDistance": 0.0,
        "TickRate": 0.0,
    },{
        "Radius": 20,
        "AttractEffectiveness": 0.1,
        "resistChance": 0.0,
        "maxDistance": 0.0,
        "TickRate": 0.0,
    },
]

@onready var TickTimer:Timer = $Timer
@onready var buMan: BuildingManager = get_parent().get_parent().get_parent().get_parent().get_node("Systems/BuildingManager")
@onready var myTileCenter: Vector2i = buMan.global_to_map(get_parent().position)

var humansInRange = []

func _ready():
    TickTimer.wait_time = TickRate
    TickTimer.one_shot = false
    if Active:
        TickTimer.start()

    $CollisionShape2D.shape.radius = Radius

func _on_Area2D_body_entered(body):
    if !Active:
        return

    if !body.is_in_group("Human"):
        return
    var human = body as Human
    if randf() < AttractEffectiveness:
        humansInRange.append(human)
        var newTarget = get_random_Target(myTileCenter, human)
        if newTarget == null:
            return
        human._set_target(newTarget)
        human.setWaitAfterTargetReached(true)

# Returns a random target that is not more than maxDistance away from the human or else null 
func get_random_Target(tilePos: Vector2, human: Human):
    var globalPos = buMan.map_to_global(tilePos)
    var newTargets: Array[Vector2] = human.get_nearest_Points(tilePos, 10)
    var newTargetIndex = randi() % newTargets.size()
    var newTarget: Vector2 = buMan.map_to_global(newTargets[newTargetIndex])
    var distance: float = newTarget.distance_to(globalPos)
    while distance > maxDistance:
        newTargetIndex -= 1
        if newTargetIndex == -1:
            return null
        newTarget = newTargets[newTargetIndex]
        distance = newTarget.distance_to(globalPos)
    return buMan.global_to_map(newTarget)

func _on_Area2D_body_exited(body):
    if !Active:
        return

    if !body.is_in_group("Human"):
        return
    (body as Human).setWaitAfterTargetReached(false)
    humansInRange.erase(body as Human)

func _tick():
    if !Active:
        return

    for human in humansInRange:
        if randf() > resistChance:
            continue
        human.setWaitAfterTargetReached(false)

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

func getUpgradeCost(level:int):
    return Upgrades[level]["Cost"]

func upgrade(level:int):
    if level >= Upgrades.size():
        print("Upgrade level is too high")
        return

    Radius += Upgrades[level]["Radius"]
    AttractEffectiveness += Upgrades[level]["AttractEffectiveness"]
    resistChance += Upgrades[level]["resistChance"]
    maxDistance += Upgrades[level]["maxDistance"]
    TickRate += Upgrades[level]["TickRate"]

    applyNewValues()

func applyNewValues():
    $CollisionShape2D.shape.radius = max(Radius, 1)
    TickTimer.wait_time = max(TickRate, 0.1)
    
    AttractEffectiveness = clamp(AttractEffectiveness, 0.0, 1.0)
    resistChance = clamp(resistChance, 0.0, 1.0)
    maxDistance = clamp(maxDistance, 0.0, Radius)