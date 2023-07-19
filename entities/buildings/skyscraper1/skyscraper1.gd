extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
    $Timer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _toggle_hide():
    if $AnimatedSprite2D.animation == "default":
        $AnimatedSprite2D.animation = "hidden"
    else:
        $AnimatedSprite2D.animation = "default"
