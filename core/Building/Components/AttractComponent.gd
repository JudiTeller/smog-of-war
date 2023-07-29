extends Area2D

@export var Active: bool = true
@export var Radius: float = 100.0
@export var AttractAmount: float = 1 # 1 People per Tick
@export var AttractEffectiveness: float = 0.5 # 50% of the people are attracted

@onready var TickTimer:Timer = $Timer
@onready var buMan: BuildingManager = get_parent().get_parent().get_parent().get_parent().get_node("Systems/BuildingManager")
@onready var myGlobalTileCenter: Vector2 = buMan.map_to_global(buMan.global_to_map(position))

var humansInRange = []

func _ready():
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    if Active:
        TickTimer.start()

    $CollisionShape2D.shape.radius = Radius

func _on_Area2D_body_entered(body):
    if !body.is_in_group("Human"):
        return
    humansInRange.append(body as Human)

func _on_Area2D_body_exited(body):
    if !body.is_in_group("Human"):
        return
    (body as Human)._set_target((body as Human).get_random_target_position())
    humansInRange.erase(body as Human)

func _tick():
    if !Active:
        return

    var attracted = 0
    for human in humansInRange:
        if randf() < AttractEffectiveness:
            attracted += 1
            human._set_target(myGlobalTileCenter)
        if attracted >= AttractAmount:
            break

func activate():
    Active = true
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    TickTimer.start()

func deactivate():
    Active = false
    TickTimer.stop()
