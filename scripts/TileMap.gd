extends TileMap

# units
	# unit vars
var selected_unit = null
var selected_weapon_index = null
var index_to_unit = Dictionary()
var unit_to_index = Dictionary()
var player_team = "blue"
var current_team = "blue"
var teams = ["blue", "red", "green"]
	# unit info UI module
onready var selected_unit_info = get_node("../SelectedUnitInfo")
#	Sidebar for seeing all units on player team
onready var unit_selection_sidebar = get_node("../UnitSelectionSidebar/UnitSelectionSidebarGrid")
	# unit related signals
signal unit_selected # (unit)
signal unit_deselected
signal unit_moved	# (unit, tile_index, cost)
signal unit_attacks_unit # attacking_unit, attacking_unit_weapon_data, attacked_unit

# movement and attack indicator
onready var movement_overlay = get_node("MovementAttackOverlay")
	# used for checking what to do if a tile is clicked when a unit is selected; eg what overlay is being used
const SELECTION_MODE = "selection"
const MOVE_MODE = "move"
const ATTACK_MODE = "attack"
var movement_mode = SELECTION_MODE	 # what to do when a tile is clicked

	# movement overlay signals
signal clear_movement_tiles 
signal create_movement_tiles # (bfs_results)
	# attack overlay signal
signal clear_attack_tiles
signal create_attack_tiles
	
var last_bfs = Dictionary() # last pathing result from self.get_bfs. Used for checking movement. tile_indexes:cost
var last_attack_pattern = Dictionary() # last calculated attack pattern. Used for checking attacks. tile_indexes:attack_data


onready var unit_asset = preload("res://scenes/Unit.tscn") # unit prefab
onready var unit_sidebar_asset = preload("res://scenes/UnitSideBarButton.tscn") # unit prefab

var directions = {
		"north": Vector2(0,-1),
		"south": Vector2(0,1),
		"east": Vector2(1,0),
		"west": Vector2(-1,0)
		}

func _ready():
	selected_unit_info.hide()
	get_tree().call_group("units", "_on_start_team_turn", current_team)

####### Spawning and Saving units #####

func _on_batch_spawn_units(data):
	# Spawn units from a JSON payload
	for unit_id in data:
		var unit_data = data[unit_id]
		var unit_tile_index = Vector2(unit_data["unit_tile_index"][0], unit_data["unit_tile_index"][1]) # convert the json array to vector2
		self.spawn_unit(unit_tile_index, unit_data)

func spawn_unit(tile_index, unit_args):
	# initialize positioning, node hiearchy, and unit arguments
	var unit = unit_asset.instance()
	var unit_position = map_to_world(tile_index)
	unit.init(unit_position,unit_args)
	self.add_child(unit)
	
	# set unit signal bindings
	unit.connect("click_unit", self, "_on_click_unit")
	unit.connect("kill_unit", self, "_on_kill_unit")
	self.connect("unit_selected", unit, "_on_unit_selected")
	self.connect("unit_deselected", unit, "_on_unit_deselected")
	self.connect("unit_moved", unit, "_on_unit_moved")
	self.connect("unit_attacks_unit", unit, "_on_unit_attacks_unit")
	
	# initialize tile index <-> unit bindings
	unit_to_index[unit] = tile_index
	index_to_unit[tile_index] = unit
	
	# initialize sidebar unit UI for those belonging to the player team
	if unit.unit_team == player_team:
		var sidebar_unit = unit_sidebar_asset.instance()
		sidebar_unit.unit = unit
		sidebar_unit.text = unit.unit_name
		self.unit_selection_sidebar.add_child(sidebar_unit)
		
		# signal bindings
		sidebar_unit.connect("unit_sidebar_pressed", self, "attempt_select_unit")
		
		unit.connect("kill_unit", sidebar_unit, "_on_kill_unit")
	
################ Clicking #############
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			var tile_index = world_to_map(mouse_pos)
			click_tile(tile_index)
		if event.button_index == BUTTON_RIGHT:
			deselect_unit()

func click_tile(tile_index):
	var tile_pos = map_to_world(tile_index)
	
	if movement_mode == SELECTION_MODE:
		# if another unit is at clicked tile
		if index_to_unit.has(tile_index):
				attempt_select_unit(index_to_unit[tile_index])	# select unit
	else:
		# movement and attacking
		if selected_unit != null:
			# try to move the unit to tile
			if movement_mode == MOVE_MODE:
				# if there's not another unit there
				if not index_to_unit.has(tile_index):
					if self.selected_unit.unit_can_move:
						if self.last_bfs.has(tile_index):
							self.move_unit_to_tile(selected_unit, tile_index)
				else:
					attempt_select_unit(index_to_unit[tile_index])
			# try to attack the tile
			elif movement_mode == ATTACK_MODE and self.selected_unit.unit_can_attack:
				if self.last_attack_pattern.has(tile_index):
					self.unit_attack_tile(selected_unit, selected_weapon_index, tile_index)

func _on_click_unit(unit):
	return
	print(unit)
	selected_unit = unit
	
################ Unit selection and deselection ###########

func attempt_select_unit(unit):
	# code checking if a unit even can be selected before actually selecting
	if unit.unit_team == player_team:
		if unit.unit_team == self.current_team:
			if unit.unit_can_move or unit.unit_can_attack:
				select_unit(unit)

func select_unit(unit):
	deselect_unit()
	# select new unit
	selected_unit = unit
	emit_signal("unit_selected", self.selected_unit)
	
	if unit.unit_can_move:
		self.get_bfs(unit)
		emit_signal("create_movement_tiles", self.last_bfs)
		self.movement_mode = MOVE_MODE

func deselect_unit():
	if selected_unit != null:
		emit_signal("unit_deselected", self.selected_unit)
		emit_signal("clear_movement_tiles")
	selected_unit = null
	selected_weapon_index = null
	self.movement_mode = SELECTION_MODE
	
	
################## Unit moving and attacking ##############

func move_unit_to_tile(unit, tile_index):
	print("Tilemap: moving unit ", unit.unit_name, " to ", tile_index)  
	
	# restrict movement to defined tiles
	if get_cell(tile_index[0],tile_index[1]) != INVALID_CELL:
		var tile_pos = map_to_world(tile_index)
		unit.position = tile_pos
		
		# erase old index to unit to prevent duplicates
		index_to_unit.erase(unit_to_index[unit])
		# update tile index <-> unit bindings
		unit_to_index[unit] = tile_index
		index_to_unit[tile_index] = unit
		
		emit_signal("unit_moved", unit, tile_index, self.last_bfs[tile_index]) 
		emit_signal("clear_movement_tiles")
		last_bfs.clear()	# clear the cache to prevent accessing old tiles after moving
		
func unit_attack_tile(unit, weapon_index, tile_index):
	print("Tilemap: attacking tile ",tile_index, " with ", unit.unit_name, " damage:", unit.unit_weapon_data[weapon_index]["damage"])
	if self.index_to_unit.has(tile_index):
		emit_signal("unit_attacks_unit", unit, unit.unit_weapon_data[weapon_index], self.index_to_unit[tile_index])
	self.deselect_unit()
	unit.set_unit_can_attack(false)
	unit.set_unit_can_move(false)
	emit_signal("clear_attack_tiles")
	last_attack_pattern.clear()	# clear the cache to prevent accessing old tiles after moving
	
func _on_kill_unit(unit):
	print("TileMap: Killed unit ", unit.unit_name)
	if unit == self.selected_unit:
		deselect_unit()
	
	var tile_index = self.unit_to_index[unit]
	self.unit_to_index.erase(unit)
	self.index_to_unit.erase(tile_index)
	unit.queue_free()

################## UI Buttons ##################

func _on_EndTurnButton_button_up():
	self.deselect_unit()
	get_tree().call_group("units", "_on_end_team_turn", current_team)
	current_team = teams[(teams.find(current_team) + 1) % len(teams)]
	print("current team: "+current_team)
	get_tree().call_group("units", "_on_start_team_turn", current_team)
	
func _on_ItemButton_button_up(weapon_index):
	# Button for selecting items to attack with
	if self.selected_unit.unit_can_attack:
		# weapon selected
		selected_weapon_index = weapon_index
		print("Tilemap: weapon index selected: ", weapon_index)
		var attackable_tiles = calculate_attackable_tiles(self.selected_unit, weapon_index)
		emit_signal("create_attack_tiles", attackable_tiles)
		self.movement_mode = ATTACK_MODE
	
####################### Tile based functions ###################

func _on_set_tiles(tile_data):
	# sets the tiles in the tilemap from a JSON payload
	# Usually used for initialization but can also batch edit tiles on demand
	print("Tilemap: setting tiles")
	for tile in tile_data["tiles"]:
		self.set_cell(tile[0],tile[1], tile[2])
	
func get_bfs(unit):
	# returns all the tile indexes that a unit can move to
	var moveable_tile_indexes = Dictionary(); # end result. maps tile_index:cost
	var unvisited_tiles = []
	var starting_point = unit_to_index[unit]
	unvisited_tiles.append(starting_point)
	moveable_tile_indexes[starting_point] = 0

	var current_index
	var possible_index

	while(len(unvisited_tiles)):
		current_index = unvisited_tiles.pop_front()
		for direction in self.directions:
			possible_index = current_index + self.directions[direction]
			if self.get_cell(possible_index.x, possible_index.y) != INVALID_CELL:
				if not moveable_tile_indexes.has(possible_index):
					if moveable_tile_indexes[current_index] + 1 <= unit.unit_movement_points:
						unvisited_tiles.append(possible_index)
						moveable_tile_indexes[possible_index] = moveable_tile_indexes[current_index] + 1
	
	moveable_tile_indexes.erase(starting_point)
	self.last_bfs = moveable_tile_indexes
	return moveable_tile_indexes;

func filter_tiles_in_bounds(tile_indexes : Array) -> Array:
	# helper method
	# takes a list of tile indexes and returns a filtered version of all indexes that are defined
	var filtered_tiles = []
	for tile_index in tile_indexes:
		if self.get_cell(tile_index.x, tile_index.y) != INVALID_CELL:
			 filtered_tiles.append(tile_index)
	return filtered_tiles

#################### Attack pattern generators ####################

func calculate_attackable_tiles(unit, weapon_index):
	# given a unit and weapon calculate the tiles it can attack given the weapon pattern in the unit's weapon data
	# the weapon pattern name decides which functions will be applied to get the tiles
	var attackable_pattern = Dictionary() # pattern of tile_indexes:attack_data
	var unit_index = self.unit_to_index[unit]
	var weapon_pattern : Dictionary = unit.unit_weapon_data[weapon_index].get("weapon_pattern")
	if weapon_pattern["pattern"] == "cardinal":
		attackable_pattern = attack_pattern_cardinal(unit_index, weapon_pattern.get("size"))
	self.last_attack_pattern = attackable_pattern
	return attackable_pattern

func attack_pattern_cardinal(unit_tile_index : Vector2, size : int):
	# generates a filtered attack pattern in the cardinals of length size
	var attackable_tiles = Dictionary()
	
	for direction in self.directions:
		for scalar in range(size):
			var attack_tile = unit_tile_index + (self.directions[direction] * (scalar + 1))
			if self.get_cell(attack_tile.x, attack_tile.y) != INVALID_CELL:
				attackable_tiles[attack_tile] = {"direction":direction}
	return attackable_tiles
	

	