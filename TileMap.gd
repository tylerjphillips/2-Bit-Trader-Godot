extends TileMap

signal unit_selected
signal unit_deselected
var selected_unit = null
onready var unit_asset = preload("res://Unit.tscn")
onready var cursor_asset = preload("res://Cursor.tscn")
onready var selected_unit_info = get_node("../SelectedUnitInfo")
var cursor

var index_to_unit = Dictionary()
var unit_to_index = Dictionary()
var player_team = "blue"
var current_team = "blue"
var teams = ["blue", "red", "green"]

func _ready():
	selected_unit_info.hide()
	
	cursor = cursor_asset.instance() # cursor used to show selected units
	var unit_args = {"unit_name": "Jerry", 
		"unit_health_points": 3, 
		"unit_health_points_max": 4,
		"unit_team":"blue"}
	spawn_unit(Vector2(10,5), unit_args)
	unit_args = {"unit_name": "Bob", 
		"unit_health_points": 3, 
		"unit_health_points_max": 3}
	spawn_unit(Vector2(11,5), unit_args)
	unit_args = {"unit_name": "Mike", 
		"unit_health_points": 2, 
		"unit_health_points_max": 5}
	spawn_unit(Vector2(12,5), unit_args)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			var tile_index = world_to_map(mouse_pos)
			click_tile(tile_index)
		if event.button_index == BUTTON_RIGHT:
			deselect_unit()

func spawn_unit(tile_index, unit_args):
	var unit = unit_asset.instance()
	var unit_position = map_to_world(Vector2(tile_index[0], tile_index[1]))
	unit.init(unit_position,unit_args)
	
	self.add_child(unit)
	self.connect("unit_selected", unit, "_on_unit_selected")
	self.connect("unit_deselected", unit, "_on_unit_deselected")	
	unit_to_index[unit] = tile_index
	index_to_unit[tile_index] = unit
	
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
	var tile_pos = map_to_world(tile_index)
	# set_cell(tile_index[0],tile_index[1], 2) # 2 is the index of a tile in the tilemap
	# if unit at clicked tile
	if index_to_unit.has(tile_index):
		select_unit(index_to_unit[tile_index])	# select unit
	else:
		if selected_unit != null:
			move_unit(selected_unit, tile_index)

func select_unit(unit):
	if unit.unit_team == player_team:
		if unit.unit_team == self.current_team:
			# move cursor
			deselect_unit()
			unit.add_child(cursor)
			# select new unit
			selected_unit = unit
			emit_signal("unit_selected", self.selected_unit)
	
func deselect_unit():
	if selected_unit != null:
		emit_signal("unit_deselected", self.selected_unit)
		selected_unit.remove_child(cursor)
	selected_unit = null

func _on_EndTurnButton_button_up():
	get_tree().call_group("units", "_on_end_team_turn", current_team)
	current_team = teams[(teams.find(current_team) + 1) % len(teams)]
	print("current team: "+current_team)
	get_tree().call_group("units", "_on_start_team_turn", current_team)
	pass # Replace with function body.
