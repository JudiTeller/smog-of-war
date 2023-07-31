extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

const BASE_SPEED = 10
var cur_speed = BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


func _unhandled_input(event):
        # simple camera movement

    if Input.is_action_pressed("ui_right"):
        position.x += cur_speed
    if Input.is_action_pressed("ui_left"):
        position.x -= cur_speed
    if Input.is_action_pressed("ui_up"):
        position.y -= cur_speed
    if Input.is_action_pressed("ui_down"):
        position.y += cur_speed

    # zoom in and out with mouse wheel
    var newZoom = get_zoom().x
    if Input.is_action_just_released('wheel_down'):
        newZoom -= 0.25
    if Input.is_action_just_released('wheel_up'):
        newZoom += 0.25
    newZoom = max(0.25, newZoom)
    set_zoom(Vector2(newZoom, newZoom))
