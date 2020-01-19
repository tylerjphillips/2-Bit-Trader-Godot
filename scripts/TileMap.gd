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
signal unit_collides_unit # (attacking_unit, affected_unit, collision_count, collided_unit)

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

onready var unit_asset = preload("res://scenes/Unit.tscn") # unit prefab
onready var unit_sidebar_asset = preload("res://scenes/UnitSideBarButton.tscn") # unit prefab

var directions = {
		"north": Vector2(0,-1),
		"south": Vector2(0,1),
		"east": Vector2(1,0),
		"west": Vector2(-1,0)
		}

func _ready():
	get_tree().call_group("units", "_on_start_team_turn", current_team)
	
	assert selected_unit_info

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
	self.add_child(unit)
	unit.init(unit_position,unit_args)
	
	# set unit signal bindings
	unit.connect("click_unit", self, "_on_click_unit")
	unit.connect("kill_unit", self, "_on_kill_unit")
	self.connect("unit_selected", unit, "_on_unit_selected")
	self.connect("unit_deselected", unit, "_on_unit_deselected")
	self.connect("unit_moved", unit, "_on_unit_moved")
	self.connect("unit_attacks_unit", unit, "_on_unit_attacks_unit")
	self.connect("unit_collides_unit", unit, "_on_unit_collides_unit")
	
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
						if selected_unit.last_bfs.has(tile_index):
							emit_signal("unit_moved", selected_unit, tile_index, self.selected_unit.last_bfs[tile_index]) 
							emit_signal("clear_movement_tiles")
							self.selected_unit.last_bfs.clear()	# clear the cache to prevent accessing old tiles after moving
							self.move_unit_to_tile(selected_unit, tile_index)
				else:
					attempt_select_unit(index_to_unit[tile_index])
			# try to attack the tile
			elif movement_mode == ATTACK_MODE and self.selected_unit.unit_can_attack:
				if selected_unit.last_attack_pattern.has(tile_index):
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
		emit_signal("create_movement_tiles", unit.last_bfs)
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
		
		
		
func unit_attack_tile(attacking_unit, weapon_index, tile_index):
	# unit attacks a tile with a given weapon
	print("Tilemap: attacking tile ",tile_index, " with ", attacking_unit.unit_name, " damage:", attacking_unit.unit_weapon_data[weapon_index]["damage"])
	
	#TODO calculate damage pattern and apply attack to multiple tiles 
	
	if self.index_to_unit.has(tile_index):
		var affected_unit = self.index_to_unit[tile_index]
		self.attempt_push_unit(attacking_unit, affected_unit, weapon_index, tile_index) # try to push the unit
		if self.unit_to_index.has(affected_unit):	# check if unit didn't die from possible push
			emit_signal("unit_attacks_unit", attacking_unit, attacking_unit.unit_weapon_data[weapon_index], affected_unit)
	self.deselect_unit()
	attacking_unit.set_unit_can_attack(false)
	attacking_unit.set_unit_can_move(false)
	emit_signal("clear_attack_tiles")
	attacking_unit.last_attack_pattern.clear()	# clear the cache to prevent accessing old tiles after moving
	
func attempt_push_unit(attacking_unit, affected_unit, weapon_index, tile_index):
	# attempt to push an attacked unit a number of tiles indicated by last_attack_pattern and the weapon's push scalar. Negative scalars allowed
	# if units are pushed into things then collisions are generated
	var affected_unit_tile_index : Vector2 = self.unit_to_index[affected_unit]
	var pushed_into_tile_index	: Vector2 = affected_unit_tile_index	# where the affected unit winds up
	var push_scalar : int = attacking_unit.unit_weapon_data[weapon_index].get("push_scalar", 0)		# the amount of tiles the attack will push. 0 if undefined
	var push_direction : Vector2 = attacking_unit.last_attack_pattern[affected_unit_tile_index]["direction"]
	# collision vars
	var collision_count : int = 0 # number of times attempting to move into a tile would cause a collision. Used for damage calculations
	var collided_unit = null	# the unit that the affected unit may collide with
	
	if push_scalar != 0:
		assert push_direction in self.directions	# weapon push direction must be defined
		
		# unit will be moved as many times over in the attack direction as possible, counting collisions made and then pushing the unit where needed
		for i in range(push_scalar):
			var checking_index = pushed_into_tile_index + (self.directions[push_direction] * (sign(push_scalar)))
			if self.get_cell(checking_index.x, checking_index.y) != INVALID_CELL: 	# if cell is on the map
				if self.index_to_unit.has(checking_index):	# check collisions
					# collisions
					collided_unit = self.index_to_unit[checking_index]
					collision_count += 1
				else:
					# no collision; move the unit instead
					pushed_into_tile_index = checking_index  
			else:
				break	# no need to continue if you hit the edge of the map
		# push unit at the end
		self.push_unit(attacking_unit, affected_unit, pushed_into_tile_index, collision_count, collided_unit)
			
func push_unit(attacking_unit, affected_unit, new_tile_index : Vector2, collision_count : int, collided_unit):
	move_unit_to_tile(affected_unit, new_tile_index)
	if collided_unit != null:
		emit_signal("unit_collides_unit", attacking_unit, affected_unit, collision_count, collided_unit)
	
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
		var attackable_tiles = calculate_attack_tiles(self.selected_unit, weapon_index)
		emit_signal("create_attack_tiles", attackable_tiles)
		self.movement_mode = ATTACK_MODE
	
####################### Tile based functions ###################

func _on_set_tiles(tile_data):
	# sets the tiles in the tilemap from a JSON payload
	# Usually used for initialization but can also batch edit tiles on demand
	print("Tilemap: setting tiles")
	for tile in tile_data["map_tiles"]:
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
	unit.last_bfs = moveable_tile_indexes
	return moveable_tile_indexes;

func filter_tiles_in_bounds(tile_indexes : Array) -> Array:
	# helper method
	# takes a list of tile indexes and returns a filtered version of all indexes that are defined
	var filtered_tiles = []
	for tile_index in tile_indexes:
		if self.get_cell(tile_index.x, tile_index.y) != INVALID_CELL:
			 filtered_tiles.append(tile_index)
	return filtered_tiles

#################### Attack and damage pattern generators ####################

func calculate_attack_tiles(attacking_unit, weapon_index):
	# given a unit and weapon calculate the tiles it can attack given the weapon attack pattern in the unit's weapon data
	# the weapon attack pattern name decides which functions will be applied to get the tiles
	var attack_pattern = Dictionary() # pattern of tile_indexes:attack_data
	var unit_index = self.unit_to_index[attacking_unit]
	var weapon_attack_pattern : Dictionary = attacking_unit.unit_weapon_data[weapon_index]["weapon_pattern"]
	if weapon_attack_pattern["pattern"] == "cardinal":
		var size : int = weapon_attack_pattern.get("size", 1)
		var blockable : bool = weapon_attack_pattern.get("blockable", false)
		attack_pattern = generate_cardinal_pattern(unit_index, size, blockable)
	if weapon_attack_pattern["pattern"] == "single":
		attack_pattern = generate_single_pattern(unit_index)
	attacking_unit.last_attack_pattern = attack_pattern
	return attack_pattern
	
func calculate_damage_tiles(attacking_unit, attacked_tile_index, weapon_index):
	# given a unit use the unit's attack pattern data and the tile it wishes to attack to generate the tiles it affects
	# the weapon damage pattern name decides which functions will be applied to get the tiles
	
	var damage_pattern = Dictionary() # pattern of tile_indexes:attack_data
	var weapon_damage_pattern : Dictionary = attacking_unit.unit_weapon_data[weapon_index]["damage_pattern"]
	var attack_tile_data = attacking_unit.last_attack_pattern[attacked_tile_index]	# data from unit's attack pattern at selected tile
	
	print("Tilemap: attack direction: ", attack_tile_data["direction"])
	
	if weapon_damage_pattern["pattern"] == "cardinal":
		var size : int = weapon_damage_pattern.get("size", 1)
		var blockable : bool = weapon_damage_pattern.get("blockable", false)
		damage_pattern = generate_cardinal_pattern(attacked_tile_index, size, blockable)
	if weapon_damage_pattern["pattern"] == "single":
		damage_pattern = generate_single_pattern(attacked_tile_index, attack_tile_data["direction"])
	attacking_unit.last_damage_pattern = damage_pattern
	return damage_pattern

func generate_cardinal_pattern(tile_index : Vector2, size := 1, blockable := false):
	# generates a filtered attack pattern in the cardinals of length size
	# if blockable units and obstacles will stop it
	var attackable_tiles = Dictionary()
	
	for direction in self.directions:
		for scalar in range(size):
			var attack_tile = tile_index + (self.directions[direction] * (scalar + 1))
			if self.get_cell(attack_tile.x, attack_tile.y) != INVALID_CELL:
				attackable_tiles[attack_tile] = {"direction":direction}
				if blockable and self.index_to_unit.has(attack_tile):
					break	
	return attackable_tiles

func generate_single_pattern(tile_index, direction = "none"):
	# generate pattern only at given tile
	# direction param used for inheriting damage direction from attack direction
	var attackable_tiles = Dictionary()
	attackable_tiles[tile_index] = {"direction": direction}
	return attackable_tiles
	

	