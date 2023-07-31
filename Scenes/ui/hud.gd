extends Control

@export var cleanse_threshold: float
@export var building_manager: BuildingManager
@export var click_manager: ClickManager
@export var resource_manager: ResourceManager
@export var cleanse_manager: CleanseManager

var current_cleanse: float


@onready var cleanse_progress: ProgressBar = $hud_canvas/Cleanse/CleanseProgress
@onready var cleanse_text: Label = $hud_canvas/Cleanse/CleanseProgress/CleanseText
@onready var humans_label: Label = $hud_canvas/Resources/Panel/NumberHumans
@onready var medic_label: Label = $hud_canvas/Resources/Panel/hud_canvas/Resources/Panel/NumberMedics
@onready var menu_button: MenuButton = $hud_canvas/MenuButton

var popup_menu: PopupMenu

# Called when the node enters the scene tree for the first time.
func _ready():
    # cleanse_progress.max_value = cleanse_threshold
    call_deferred("setup")
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    update_cleanse_progress()
    update_resources()
    pass

# setup all needed variables and building list
func setup():
    popup_menu = menu_button.get_popup()
    popup_menu.connect("id_pressed", Callable(self, "on_build_menu_item_pressed"))
    building_manager.connect("score_signal", Callable(cleanse_manager, "on_score_signal"))

    for i in range(building_manager.PLACEABLES.size()):
        var placeable_type = building_manager.PLACEABLES[i]
        var temp_instance: Building = placeable_type.instantiate()
        popup_menu.add_item(str(temp_instance.Cost))
        var icon_texture: Texture2D = temp_instance.get_child(0).sprite_frames.get_frame_texture("repaired", 0)
        popup_menu.set_item_icon(i, icon_texture)
        pass

# updates the progress bar with current values
func update_cleanse_progress():
    current_cleanse = cleanse_manager.cleanse_score
    cleanse_progress.value = current_cleanse
    cleanse_text.text = str(current_cleanse).pad_decimals(0)

# updates the resource counters with current value
func update_resources():
    humans_label.text = str(resource_manager.humans) 
    # humans_label.medics = str(resource_manager.medics) 


# selects the clicked entry from building list
func on_build_menu_item_pressed(index: int):
    click_manager.currentAction = ClickManager.Action.PLACE

    var new_building: Building = building_manager.PLACEABLES[index].instantiate()
    click_manager.selectedBuilding = new_building
    click_manager.hover_sprite.texture = new_building.get_child(0).sprite_frames.get_frame_texture("repaired", 0)
    var item_name = popup_menu.get_item_text(index)
    print(item_name)
    pass


func set_cleanse_threshold(new_threshold: float):
    cleanse_threshold = new_threshold
    cleanse_progress.max_value = cleanse_threshold
    cleanse_text.text = str(current_cleanse)
