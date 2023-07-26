extends Node

var worldsize := 0
var current_tilemap: TileMap

var walkable_nodes: Array[PackedVector2Array]

func generate_walkable_nodes():
    if current_tilemap:

        var ref_array: Array[Array] = [[]]
        var fill_in: Array[int] = []
        fill_in.resize(worldsize)
        fill_in.fill(0)
        ref_array.resize(worldsize)

        for i in range(ref_array.size()):
            ref_array[i] = fill_in.duplicate()

        # calculate lower and upper limit for coords, as word is split around scene 0,0 coordinate
        var size = worldsize/2.0

        # size to int, if size needs to be floored +1
        var upper = size
        if size - int(size) > 0.0:
            upper += 1

        for y in range(worldsize):
            for x in range(worldsize):
                # check if cell was already visited
                if ref_array[x][y] == 0:
                    var walkable = check_if_street(size, Vector2(x - size, y - size), ref_array)

                    if walkable.size() > 0:
                        walkable_nodes.append(walkable)


        # create image for debugging purposes
        # TODO REMOVE!
        var image := Image.create(worldsize, worldsize, false, Image.FORMAT_RGBA8)
        for y in range(worldsize):
            for x in range(worldsize):
                match ref_array[x][y]:
                    0:
                        image.set_pixel(x, y, Color.WHITE)

                    1:
                        image.set_pixel(x, y, Color.GRAY)

                    4:
                        image.set_pixel(x, y, Color.YELLOW)

        var mapsprite := Sprite2D.new()
        mapsprite.texture = ImageTexture.create_from_image(image)
        mapsprite.scale.x = 20
        mapsprite.scale.y = 20
        mapsprite.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST
        current_tilemap.get_parent().add_child(mapsprite)
        pass
    pass


func check_if_street(quadrant_size: int, map_location: Vector2,  ref_array: Array[Array]) -> PackedVector2Array:
    # temporary vector to hold walkable coordinates
    var temp_vec2_arr: PackedVector2Array = []

    #check if current tile was already visited
    if ref_array[map_location.x + quadrant_size][map_location.y + quadrant_size] == 0:
        ref_array[map_location.x + quadrant_size][map_location.y + quadrant_size] = 1

    # check if current tile is street
    if current_tilemap.get_cell_source_id(0, map_location) == 0:
        # check if tile has valid street texture
        if current_tilemap.get_cell_atlas_coords(0, map_location) != Vector2i(3, 3):
            ref_array[map_location.x + quadrant_size][map_location.y + quadrant_size] = 4
            temp_vec2_arr.append(map_location)

            # grow to neighbouring cells
            var neighbours: Array[Vector2i] = current_tilemap.get_surrounding_cells(map_location)
            for neighbour in neighbours:
                # check that relative neighbour coordinates are inside the ref array
                if (-quadrant_size <= neighbour.x && neighbour.x < quadrant_size) && (-quadrant_size <= neighbour.y && neighbour.y < quadrant_size):
                    if ref_array[neighbour.x + quadrant_size][neighbour.y + quadrant_size] == 0:
                        var deeper_rec = check_if_street(quadrant_size, neighbour, ref_array)
                        if deeper_rec.size() > 0:
                            for vec in deeper_rec:
                                temp_vec2_arr.append(vec)


    return temp_vec2_arr
