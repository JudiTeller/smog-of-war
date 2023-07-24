extends TileMap

var combined_poly: Array[PackedVector2Array] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    calculate_nav_area()
    call_deferred("emit_signal", "area_calculated", combined_poly[0])
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func calculate_nav_area():
#    var combined_poly: Array[PackedVector2Array] = []
    for cell in get_used_cells(0):
        var tile_nav_poly = get_cell_tile_data(0, cell).get_navigation_polygon(0).get_vertices()
        var cell_global = to_global(map_to_local(cell))
        for i in range(tile_nav_poly.size()):
            tile_nav_poly[i].x += cell_global.x
            tile_nav_poly[i].y += cell_global.y
        
        if tile_nav_poly:
            if combined_poly.size() == 0:
                combined_poly.append(tile_nav_poly)
            else:
                combined_poly = Geometry2D.merge_polygons(combined_poly[0], tile_nav_poly)
        pass



signal area_calculated(area: PackedVector2Array)
