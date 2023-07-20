extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

const BASE_SPEED = 1
var cur_speed = BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    # simple camera movement

    if Input.is_action_pressed("ui_shift"):
        cur_speed += 2
    elif Input.is_action_just_released("ui_control"):
        cur_speed -= 2
    
    cur_speed = clamp(cur_speed, 1, 10000)

    if Input.is_action_pressed("ui_right"):
        position.x += cur_speed
    if Input.is_action_pressed("ui_left"):
        position.x -= cur_speed
    if Input.is_action_pressed("ui_up"):
        position.y -= cur_speed
    if Input.is_action_pressed("ui_down"):
        position.y += cur_speed

    # zoom in and out with mouse wheel
    if Input.is_action_pressed("ui_page_up"): #FIXME
        zoom /= 1.1
    if Input.is_action_pressed("ui_page_down"):
        zoom *= 1.1
