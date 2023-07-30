extends CanvasLayer

@export var cleanse_threshold: float
@export var click_manager: ClickManager
@export var resource_manager: RessourceManager
var current_cleanse: float


@onready var cleanse_progress: ProgressBar = $Cleanse/CleanseProgress
@onready var cleanse_text: Label = $Cleanse/CleanseProgress/CleanseText

# Called when the node enters the scene tree for the first time.
func _ready():
    cleanse_progress.max_value = cleanse_threshold
    current_cleanse = 5234
    $MenuButton.get_popup().connect("id_pressed", Callable(self, "on_build_menu_item_pressed"))
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

    cleanse_progress.value = current_cleanse
    cleanse_text.text = str(current_cleanse).pad_decimals(0)

    pass



func on_build_menu_item_pressed(index: int):
    var popup: PopupMenu = $MenuButton.get_popup()
    var item_name = popup.get_item_text(index)
    print(item_name)
    pass
