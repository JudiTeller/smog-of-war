extends TileMap



# Called when the node enters the scene tree for the first time.
func _ready():
    calculate_nav_area()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func calculate_nav_area():
    var combined_poly: PackedVector2Array = []
    for cell in get_used_cells(0):
        var tile_nav_poly = get_cell_tile_data(0, cell).get_navigation_polygon(0).get_vertices()
        
        if tile_nav_poly:
            combined_poly = Geometry2D.merge_polygons(combined_poly, tile_nav_poly)
        pass
