extends CanvasLayer

@export var cleanse_threshold: float
var current_cleanse: float


@onready var cleanse_progress: ProgressBar = $Cleanse/CleanseProgress
@onready var cleanse_text: Label = $Cleanse/CleanseProgress/CleanseText

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    current_cleanse = 123.123
    cleanse_progress.value = current_cleanse / cleanse_threshold
    cleanse_text.text = str(current_cleanse).pad_decimals(0)
    pass
