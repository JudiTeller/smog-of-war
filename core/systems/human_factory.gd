class_name HumanFactory

var maxcap = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    pass # Replace with function body.




# Triggers all functions for a cycle update
func human_routine() -> void:
    # check if enough humans are present spawn new ones if necessary


func set_maxcap(newcap: int) -> void:
    maxcap = newcap
