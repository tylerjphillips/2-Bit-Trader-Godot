extends TileMap

var selected_unit = null
onready var unit_container = get_node("PlayerParty")
onready var unit_asset = preload("res://PlayerUnit.tscn")
onready var cursor_asset = preload("res://Cursor.tscn")
var cursor

var index_to_unit = Dictionary()
var unit_to_index = Dictionary()

func _ready():
	cursor = cursor_asset.instance()
	spawn_unit(Vector2(10,5), "Jerry")
	spawn_unit(Vector2(11,5), "Bob")
	spawn_unit(Vector2(12,5), "Other Bob")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			var tile_index = world_to_map(mouse_pos)
			click_tile(tile_index)
		if event.button_index == BUTTON_RIGHT:
			deselect_unit()

func spawn_unit(tile_index, name):
	var u = unit_asset.instance()
	
	u.unit_name = name
	
	unit_container.add_child(u)
	u.position = map_to_world(Vector2(tile_index[0], tile_index[1]))
	u.connect("click_unit", self, "_on_click_unit")	
	unit_to_index[u] = tile_index
	index_to_unit[tile_index] = u
	
func move_unit(unit, tile_index):
	# restrict movement to defined tiles
	if get_cell(tile_index[0],tile_index[1]) != -1:
		var tile_pos = map_to_world(tile_index)
		unit.position = tile_pos
		
		index_to_unit.erase(unit_to_index[unit])
		unit_to_index[unit] = tile_index
		index_to_unit[tile_index] = unit

func _on_click_unit(unit):
	return
	print(unit)
	selected_unit = unit

func click_tile(tile_index):
	print(tile_index)
	var tile_pos = map_to_world(tile_index)
	# set_cell(tile_index[0],tile_index[1], 2) # 2 is the index of a tile in the tilemap
	# if unit at clicked tile
	if index_to_unit.has(tile_index):
		select_unit(index_to_unit[tile_index])	# select unit
	else:
		if selected_unit != null:
			move_unit(selected_unit, tile_index)
			
	print(selected_unit)

func select_unit(unit):
	# move cursor
	deselect_unit()
	unit.add_child(cursor)
	# select new unit
	selected_unit = unit
	
	print(unit.unit_name)
	
func deselect_unit():
	if selected_unit != null:
		selected_unit.remove_child(cursor)
	selected_unit = null