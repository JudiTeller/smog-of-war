extends Control

@export var cleanse_threshold: float
@export var building_manager: BuildingManager
@export var click_manager: ClickManager
@export var resource_manager: RessourceManager
@export var cleanse_manager: CleanseManager

var current_cleanse: float


@onready var cleanse_progress: ProgressBar = $hud_canvas/Cleanse/CleanseProgress
@onready var cleanse_text: Label = $hud_canvas/Cleanse/CleanseProgress/CleanseText
@onready var menu_button: MenuButton = $hud_canvas/MenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
    # cleanse_progress.max_value = cleanse_threshold
    call_deferred("setup")
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    update_cleanse_progress()


    pass


func setup():
    menu_button.get_popup().connect("id_pressed", Callable(self, "on_build_menu_item_pressed"))
    building_manager.connect("score_signal", Callable(cleanse_manager, "on_score_signal"))

func update_cleanse_progress():
    current_cleanse = cleanse_manager.cleanse_score
    cleanse_progress.value = current_cleanse
    cleanse_text.text = str(current_cleanse).pad_decimals(0)

func on_build_menu_item_pressed(index: int):
    click_manager.currentAction = ClickManager.Action.PLACE
    var popup: PopupMenu = menu_button.get_popup()
    var item_name = popup.get_item_text(index)
    print(item_name)
    pass


func set_cleanse_threshold(new_threshold: float):
    cleanse_threshold = new_threshold
    cleanse_progress.max_value = cleanse_threshold
    cleanse_text.text = str(current_cleanse)
