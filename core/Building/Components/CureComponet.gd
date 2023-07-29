extends Area2D

@export var Active: bool = true
@export var Radius: float = 100.0
@export var CureRate: float = 1 # 1 cure per second
@export var CureAmount: float = 1 # 1 People per Tick
@export var CureEffectiveness: float = 0.5 # 50% of the people are cured

@onready var TickTimer:Timer = $Timer

var humansInRange = []

func _ready():
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    if Active:
        TickTimer.start()

    $CollisionShape2D.shape.radius = Radius

func _on_Area2D_body_entered(body):
    print("Entered")
    if body.is_in_group("Human"):
        humansInRange.append(body.get_parent() as Human)

func _on_Area2D_body_exited(body):
    print("Exited")
    if body.is_in_group("Human"):
        humansInRange.erase(body.get_parent() as Human)

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
    print("Cured: ", cured)

func activate():
    Active = true
    TickTimer.wait_time = 1.0
    TickTimer.one_shot = false
    TickTimer.start()

func deactivate():
    Active = false
    TickTimer.stop()
