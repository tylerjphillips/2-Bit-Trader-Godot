extends TileMap

# units
	# unit vars
var selected_unit = null
var index_to_unit = Dictionary()
var unit_to_index = Dictionary()
var player_team = "blue"
var current_team = "blue"
var teams = ["blue", "red", "green"]
	# unit info UI module
onready var selected_unit_info = get_node("../SelectedUnitInfo")
	# unit related signals
signal unit_selected # (unit)
signal unit_deselected
signal unit_moved	# (unit, tile_index)

# movement indicator
onready var movement_overlay = get_node("MovementOverlay")
	# movement overlay signals
signal clear_movement_tiles 
signal create_movement_tiles # (bfs_results)
	
var last_bfs = Dictionary() # last pathing result from self.get_bfs

onready var unit_asset = preload("res://Unit.tscn")


func _ready():
	selected_unit_info.hide()
	get_tree().call_group("units", "_on_start_team_turn", current_team)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			var tile_index = world_to_map(mouse_pos)
			click_tile(tile_index)
		if event.button_index == BUTTON_RIGHT:
			deselect_unit()

func _on_batch_spawn_units(data):
	# Spawn units from a JSON payload
	for unit in data:
		var unit_tile_index = Vector2(unit["unit_tile_index"][0], unit["unit_tile_index"][1]) # convert the json array to vector2
		self.spawn_unit(unit_tile_index, unit["unit_data"])

func spawn_unit(tile_index, unit_args):
	# initialize positioning, node hiearchy, and unit arguments
	var unit = unit_asset.instance()
	var unit_position = map_to_world(tile_index)
	unit.init(unit_position,unit_args)
	self.add_child(unit)
	
	# set signal bindings
	unit.connect("click_unit", self, "_on_click_unit")
	self.connect("unit_selected", unit, "_on_unit_selected")
	self.connect("unit_deselected", unit, "_on_unit_deselected")
	self.connect("unit_moved", unit, "_on_unit_moved")
	
	# initialize tile index <-> unit bindings
	unit_to_index[unit] = tile_index
	index_to_unit[tile_index] = unit
	
	unit._on_start_team_turn(current_team)
	
func move_unit(unit, tile_index):
	print("Tilemap: moving unit ", unit.name, "to", tile_index)  
	
	# restrict movement to defined tiles
	if get_cell(tile_index[0],tile_index[1]) != INVALID_CELL:
		var tile_pos = map_to_world(tile_index)
		unit.position = tile_pos
		
		# erase old index to unit to prevent duplicates
		index_to_unit.erase(unit_to_index[unit])
		# update tile index <-> unit bindings
		unit_to_index[unit] = tile_index
		index_to_unit[tile_index] = unit
		
		emit_signal("unit_moved", unit, tile_index) 
		emit_signal("clear_movement_tiles")
		last_bfs.clear()	# clear the cache to prevent accessing old tiles after moving

func _on_click_unit(unit):
	return
	print(unit)
	selected_unit = unit

func click_tile(tile_index):
	var tile_pos = map_to_world(tile_index)
	# if another unit is at clicked tile
	if index_to_unit.has(tile_index):
		attempt_select_unit(index_to_unit[tile_index])	# select unit
	else:
		if selected_unit != null:
			if self.last_bfs.has(tile_index):
				move_unit(selected_unit, tile_index)

func attempt_select_unit(unit):
	if unit.unit_team == player_team:
		if unit.unit_team == self.current_team:
			if unit.unit_can_move:
				select_unit(unit)

func select_unit(unit):
	deselect_unit()
	# select new unit
	selected_unit = unit
	emit_signal("unit_selected", self.selected_unit)
	self.get_bfs(unit)
	emit_signal("create_movement_tiles", self.last_bfs)

func deselect_unit():
	if selected_unit != null:
		emit_signal("unit_deselected", self.selected_unit)
	selected_unit = null

func _on_EndTurnButton_button_up():
	self.deselect_unit()
	get_tree().call_group("units", "_on_end_team_turn", current_team)
	current_team = teams[(teams.find(current_team) + 1) % len(teams)]
	print("current team: "+current_team)
	get_tree().call_group("units", "_on_start_team_turn", current_team)
	pass # Replace with function body.
	
func get_bfs(unit):
	# returns all the tile indexes that a unit can move to
	var moveable_tile_indexes = Dictionary(); # end result. maps tile_index:cost
	var unvisited_tiles = []
	var starting_point = unit_to_index[unit]
	unvisited_tiles.append(starting_point)
	moveable_tile_indexes[starting_point] = 0
	var directions = {
		"north": Vector2(0,-1),
		"south": Vector2(0,1),
		"east": Vector2(1,0),
		"west": Vector2(-1,0)
		}
	var current_index
	var possible_index

	while(len(unvisited_tiles)):
		current_index = unvisited_tiles.pop_front()
		for direction in directions:
			possible_index = current_index + directions[direction]
			if self.get_cell(possible_index.x, possible_index.y) != INVALID_CELL:
				if not moveable_tile_indexes.has(possible_index):
					if moveable_tile_indexes[current_index] + 1 <= unit.unit_movement_points:
						unvisited_tiles.append(possible_index)
						moveable_tile_indexes[possible_index] = moveable_tile_indexes[current_index] + 1

	self.last_bfs = moveable_tile_indexes
	return moveable_tile_indexes;
