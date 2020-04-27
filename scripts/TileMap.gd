extends TileMap

# units
	# unit vars
var selected_unit = null
var selected_weapon_id = null
var index_to_unit = Dictionary()
var unit_to_index = Dictionary()
var player_team : String
var current_team : String
var teams : Array

# tilemap hover
var currently_hovered_tile_index = Vector2(0,0)	# used for detecting changes in the hovered over tile
	
	# unit info UI module
onready var selected_unit_info = get_node("../SelectedUnitInfo")
onready var selection_cursor = get_node("SelectionCursor")
onready var movement_attack_overlay = get_node("MovementAttackOverlay") # movement and attack indicator

	# unit related signals
signal unit_selected # (unit)
signal unit_deselected
signal unit_moved	# (unit, previous_tile_index, tile_index, cost)
signal unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data)
signal unit_attacks_unit # attacking_unit, damage_pattern, attacked_unit
signal unit_collides_unit # (attacking_unit, affected_unit, collision_count, collided_unit)

	# used for checking what to do if a tile is clicked when a unit is selected; eg what overlay is being used
const SELECTION_MODE = "selection"
const MOVE_MODE = "move"
const ATTACK_MODE = "attack"
const PLACEMENT_MODE = "placement"
var movement_mode = SELECTION_MODE	 # what to do when a tile is clicked

	# turns
signal team_start_turn # (team)
signal team_end_turn # (team)
signal round_started
signal round_ended
	# damage previews
signal tilemap_damage_preview # (damage_pattern)		When a tile is hovered over communicate the damage pattern at that tile

onready var unit_asset = preload("res://scenes/combat/Unit.tscn") # unit prefab
onready var combat_selection_modal = preload("res://scenes/combat/CombatPartySelectionModal.tscn")

var directions = {
		"north": Vector2(0,-1),
		"south": Vector2(0,1),
		"east": Vector2(1,0),
		"west": Vector2(-1,0)
		}

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# emitters
	self.connect("unit_selected", relay, "_on_unit_selected")
	self.connect("unit_deselected", relay, "_on_unit_deselected")
	self.connect("unit_moved", relay, "_on_unit_moved")
	self.connect("unit_attacks_tile", relay, "_on_unit_attacks_tile")
	self.connect("unit_attacks_unit", relay, "_on_unit_attacks_unit")
	self.connect("unit_collides_unit", relay, "_on_unit_collides_unit")
	
	self.connect("team_start_turn", relay, "_on_team_start_turn")
	self.connect("team_end_turn", relay, "_on_team_end_turn")
	
	self.connect("round_started", relay, "_on_round_started")
	self.connect("round_ended", relay, "_on_round_ended")
	
	self.connect("tilemap_damage_preview", relay, "_on_tilemap_damage_preview")
	
	# listeners
	$TileMapMouseHandler.connect("tilemap_left_click", self, "_on_tilemap_left_click")
	$TileMapMouseHandler.connect("tilemap_hover", self, "_on_tilemap_hover")
	$TileMapMouseHandler.connect("tilemap_right_click", self, "_on_tilemap_right_click")
	
	relay.connect("unit_clicked", self, "_on_unit_clicked")
	relay.connect("unit_killed", self, "_on_unit_killed")
	relay.connect("unit_sidebar_pressed", self, "attempt_select_unit")
	relay.connect("unit_info_weapon_selected", self, "_on_unit_info_weapon_selected")
	relay.connect("undo_button_pressed", self, "_on_undo_button_pressed")
	relay.connect("end_turn_button_pressed", self, "_on_end_turn_button_pressed")
	
	relay.connect("combat_party_selection_finished", self, "_on_combat_party_selection_finished")
	
	get_tree().call_group("units", "_on_start_team_turn", current_team)
	
func init():
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var tile_data = current_event_data["map_tiles"]
	
	self.player_team = self.root.game_data["main_data"]["player_team"]
	self.teams = current_event_data["event_teams"]
	self.current_team = current_event_data["event_current_team"]

	var event_unit_ids = current_event_data["event_unit_ids"]
	var party_unit_ids = self.root.game_data["main_data"]["party_unit_ids"]
	self.batch_spawn_units(event_unit_ids)
	self.set_tiles(tile_data)
	
	var event_current_round = current_event_data["event_current_round"]
	if event_current_round == 0:
		self.movement_mode = PLACEMENT_MODE
		#self.movement_attack_overlay.create_placement_tiles(current_event_data["event_party_starting_positions"])
		# add combat selection modal
		var ui_element = self.combat_selection_modal.instance()
		self.add_child(ui_element)
		ui_element.init()


####### Spawning units #####

func _on_combat_party_selection_finished(selected_party_unit_ids):
	# set the selected units tile index to their starting positions defined by event_party_starting_positions, add them to the event, then spawn them
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var event_party_starting_positions : Array = current_event_data["event_party_starting_positions"]
	for i in range(len(selected_party_unit_ids)):
		var unit_id = selected_party_unit_ids[i]	# get unit id of each selected unit
		self.root.game_data["unit_data"][unit_id]["unit_tile_index"] = event_party_starting_positions[i]	# set its tile index to a starting point
		self.root.game_data["event_data"][current_event_id]["event_unit_ids"].append(unit_id) # add unit to event units
	
	batch_spawn_units(selected_party_unit_ids)
	emit_signal("round_ended")
	emit_signal("round_started")
	self.movement_mode = SELECTION_MODE

func batch_spawn_units(unit_ids):
	# Spawn units from a list of unit ids
	for unit_id in unit_ids:
		var unit_data = self.root.game_data["unit_data"][unit_id]
		var unit_tile_index = Vector2(unit_data["unit_tile_index"][0], unit_data["unit_tile_index"][1]) # convert the json array to vector2
		self.spawn_unit(unit_tile_index, unit_data)

func spawn_unit(tile_index, unit_args):
	# initialize positioning, node hiearchy, and unit arguments
	var unit = unit_asset.instance()
	var unit_position = map_to_world(tile_index)
	self.add_child(unit)
	unit.init(unit_position,unit_args)

	# initialize tile index <-> unit bindings
	unit_to_index[unit] = tile_index
	index_to_unit[tile_index] = unit
	
################ Mouse Related #############

func _on_tilemap_left_click():
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_index = world_to_map(mouse_pos)
	click_tile(tile_index)

func _on_tilemap_hover():
	# user hovered over a tile
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_index = world_to_map(mouse_pos)
	
	# a different tile has been hovered over
	if self.currently_hovered_tile_index != tile_index:
		self.currently_hovered_tile_index = tile_index
		
		# place the cursor at the tile user is hovering over
		if self.get_cell(tile_index[0], tile_index[1]) != INVALID_CELL:
			self.selection_cursor.position = map_to_world(tile_index)
			
			# create an attack preview if user is selecting an attack
			if movement_mode == ATTACK_MODE and self.selected_unit.unit_can_attack:
				if selected_unit.last_attack_pattern.has(tile_index):
					var damage_pattern = calculate_damage_pattern(self.selected_unit, self.selected_weapon_id, tile_index)
					self.movement_attack_overlay.create_damage_tiles(self.selected_unit.last_attack_pattern, damage_pattern)
					emit_signal("tilemap_damage_preview", damage_pattern)

func _on_tilemap_right_click():
	deselect_unit()

func click_tile(tile_index):
	# handle the logic for clicking at a given tile index
	var tile_pos = map_to_world(tile_index)
	
	if movement_mode == PLACEMENT_MODE:
		pass
	
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
							var previous_tile_index = self.unit_to_index[selected_unit]
							emit_signal("unit_moved", selected_unit, previous_tile_index, tile_index, self.selected_unit.last_bfs[tile_index]) 
							movement_attack_overlay.clear_movement_tiles()
							self.selected_unit.last_bfs.clear()	# clear the cache to prevent accessing old tiles after moving
							self.move_unit_to_tile(selected_unit, tile_index)
				else:
					attempt_select_unit(index_to_unit[tile_index])
			# try to attack the tile
			elif movement_mode == ATTACK_MODE and self.selected_unit.unit_can_attack:
				if selected_unit.last_attack_pattern.has(tile_index):
					self.unit_attack_tile(selected_unit, selected_weapon_id, tile_index)

func _on_unit_clicked(unit):
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
	selection_cursor.modulate = self.root.colors[unit.unit_team]
	selection_cursor.show()
	
	if unit.unit_can_move:
		self.get_bfs(unit)
		self.movement_attack_overlay.create_movement_tiles(unit.last_bfs)
		self.movement_mode = MOVE_MODE

func deselect_unit():
	selection_cursor.hide()
	
	if selected_unit != null:
		emit_signal("unit_deselected", self.selected_unit)
		self.movement_attack_overlay.clear_attack_tiles()
	selected_unit = null
	selected_weapon_id = null
	self.movement_mode = SELECTION_MODE
	
	
################## Unit moving and attacking ##############

func move_unit_to_tile(unit, tile_index):
	print("Tilemap: moving unit ", unit.unit_name, " to ", tile_index)  
	
	# restrict movement to defined tiles
	if get_cell(tile_index[0],tile_index[1]) != INVALID_CELL:
		var tile_pos = map_to_world(tile_index)
		unit.position = tile_pos
		unit.unit_tile_index = tile_index
		
		# erase old index to unit to prevent duplicates
		index_to_unit.erase(unit_to_index[unit])
		# update tile index <-> unit bindings
		unit_to_index[unit] = tile_index
		index_to_unit[tile_index] = unit
		
		
		
func unit_attack_tile(attacking_unit, weapon_index, tile_index):
	# unit attacks a tile with a given weapon, applying a damage pattern around it
	print("Tilemap: attacking tile ",tile_index, " with ", attacking_unit.unit_name)
	
	emit_signal("unit_attacks_tile", attacking_unit, tile_index, attacking_unit.last_attack_pattern, attacking_unit.unit_weapon_data[weapon_index])
	
	var damage_tiles = calculate_damage_pattern(attacking_unit, weapon_index, tile_index)
	for damage_tile_index in damage_tiles: 
		# create damage animations at each affected tile
		var attack_animation = attacking_unit.attack_animation_asset.instance()
		var attack_animation_position = map_to_world(damage_tile_index)
		attack_animation.position = attack_animation_position
		self.add_child(attack_animation)
		
		# check if unit there to damage
		if self.index_to_unit.has(damage_tile_index):
			var affected_unit = self.index_to_unit[damage_tile_index]
			if damage_tiles[damage_tile_index].has("push_into_tile_index"): # try to push the unit
				self.push_unit(affected_unit, damage_tiles[damage_tile_index]["push_into_tile_index"]) 
			if self.unit_to_index.has(affected_unit):	# check if unit didn't die from possible push
				emit_signal("unit_attacks_unit", attacking_unit, damage_tiles, affected_unit, damage_tile_index)

	self.deselect_unit()
	self.movement_attack_overlay.clear_attack_tiles()
	attacking_unit.last_attack_pattern.clear()	# clear the cache to prevent accessing old tiles after moving
			
func push_unit(pushed_unit, pushed_into_tile_index : Vector2):
	move_unit_to_tile(pushed_unit, pushed_into_tile_index)
	
func _on_unit_killed(killed_unit, killer_unit):
	if killed_unit == self.selected_unit:
		deselect_unit()
	
	var tile_index = self.unit_to_index[killed_unit]
	self.unit_to_index.erase(killed_unit)
	self.index_to_unit.erase(tile_index)
	
	self.place_unit_death_animation(killed_unit)
	
	killed_unit.queue_free()

func place_unit_death_animation(unit):
	# spawn a death animation for the unit at its location
	print("Tilemap: death animation placed at ", unit.unit_tile_index)
	var death_animation = unit.death_animation_asset.instance()
	var death_animation_position = map_to_world(unit.unit_tile_index)
	death_animation.position = death_animation_position
	death_animation.init(unit.unit_death_animation_frame_paths)
	self.add_child(death_animation)

################## UI Buttons ##################

func _on_undo_button_pressed(undo_unit, undo_unit_state):
	# move the unit back to its previous position and reinitialize it to its previous state
	self.move_unit_to_tile(undo_unit, undo_unit_state["unit_tile_index"])
	undo_unit.init(undo_unit.position, undo_unit_state, true)

func _on_end_turn_button_pressed():
	self.deselect_unit()
	emit_signal("team_end_turn",current_team)
	current_team = teams[(teams.find(current_team) + 1) % len(teams)]	 # rotate to next team
	
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	self.root.game_data["event_data"][current_event_id]["event_current_team"] = self.current_team
	
	print("current team: "+current_team)
	emit_signal("team_start_turn",current_team)
	
	# round ended
	if teams.find(current_team) == 0:
		emit_signal("round_ended")
		emit_signal("round_started")
	
func _on_unit_info_weapon_selected(weapon_id):
	# Button for selecting items to attack with
	if self.selected_unit.unit_can_attack:
		# weapon selected
		self.selected_weapon_id = weapon_id
		print("Tilemap: weapon id selected: ", weapon_id)
		var attackable_tiles = calculate_attack_pattern(self.selected_unit, weapon_id)
		self.movement_attack_overlay.create_attack_tiles(attackable_tiles)
		self.movement_mode = ATTACK_MODE
	
####################### Tile based functions ###################

func set_tiles(tile_data):
	# sets the tiles in the tilemap from a JSON payload
	# Usually used for initialization but can also batch edit tiles on demand
	print("Tilemap: setting tiles")
	for tile in tile_data:
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

#################### Attack and damage pattern generators ####################

func calculate_attack_pattern(attacking_unit, weapon_index):
	# given a unit and weapon calculate the tiles it can attack given the weapon attack pattern in the unit's weapon data
	# the weapon attack pattern name decides which functions will be applied to get the tiles
	var attack_pattern = Dictionary() # pattern of tile_indexes:attack_data
	var unit_index = self.unit_to_index[attacking_unit]
	var weapon_attack_pattern : Dictionary = attacking_unit.unit_weapon_data[weapon_index]["weapon_pattern"]
	if weapon_attack_pattern["pattern"] == "cardinal":
		var size : int = weapon_attack_pattern.get("size", 1)
		var blockable : bool = weapon_attack_pattern.get("blockable", false)
		var include_center : bool = weapon_attack_pattern.get("include_center", false)
		attack_pattern = generate_cardinal_pattern(unit_index, size, blockable, include_center)
	if weapon_attack_pattern["pattern"] == "single":
		attack_pattern = generate_single_pattern(unit_index)
	if weapon_attack_pattern["pattern"] == "allies":
		var include_self : bool = weapon_attack_pattern.get("include_self", false)
		attack_pattern = generate_allied_pattern(attacking_unit, include_self)
	if weapon_attack_pattern["pattern"] == "enemies":
		attack_pattern = generate_enemy_pattern(attacking_unit)
	attacking_unit.last_attack_pattern = attack_pattern
	return attack_pattern
	
func calculate_damage_pattern(attacking_unit, weapon_index, attacked_tile_index):
	# given a unit use the unit's attack pattern data and the tile it wishes to attack to generate the tiles it affects
	# the weapon damage pattern name decides which functions will be applied to get the tiles
	
	var final_damage_pattern = Dictionary() # pattern of tile_indexes:attack_data
	var weapon_damage_patterns : Dictionary = attacking_unit.unit_weapon_data[weapon_index]["damage_patterns"]
	var attack_tile_data = attacking_unit.last_attack_pattern[attacked_tile_index]	# data from unit's attack pattern at selected tile
	
	# iterate over all the damage patterns to generate a combined pattern
	for damage_pattern_data in weapon_damage_patterns:
		var damage_pattern
		
		if damage_pattern_data["pattern"] == "cardinal":
			var size : int = damage_pattern_data.get("size", 1)
			var blockable : bool = damage_pattern_data.get("blockable", false)
			var include_center : bool = damage_pattern_data.get("include_center", false)
			damage_pattern = generate_cardinal_pattern(attacked_tile_index, size, blockable, include_center)
		if damage_pattern_data["pattern"] == "single":
			damage_pattern = generate_single_pattern(attacked_tile_index, attack_tile_data["direction"])
		if damage_pattern_data["pattern"] == "allies":
			var include_self : bool = damage_pattern_data.get("include_self", false)
			damage_pattern = generate_allied_pattern(attacking_unit, include_self)
		if damage_pattern_data["pattern"] == "enemies":
			damage_pattern = generate_enemy_pattern(attacking_unit)
		
		# Tiles will only be written to once in final pattern, meaning first patterns take precedence
		for tile_index in damage_pattern:
			if !final_damage_pattern.has(tile_index):
				final_damage_pattern[tile_index] = damage_pattern[tile_index]
				final_damage_pattern[tile_index]["damage"] = damage_pattern_data["damage"]
				final_damage_pattern[tile_index]["push_scalar"] = damage_pattern_data.get("push_scalar", 0)
				
		final_damage_pattern = self.calculate_push_damage(final_damage_pattern)
					
	attacking_unit.last_damage_pattern = final_damage_pattern
	return final_damage_pattern

func calculate_push_damage(damage_pattern : Dictionary):
	# takes a damage pattern, calculates push related damage and data, and returns a new damage pattern
	var push_damage_pattern = damage_pattern.duplicate(true)	# this has to be a deep copy to make it immutable
	for tile_index in damage_pattern:
		var push_scalar : int = damage_pattern[tile_index].get("push_scalar", 0)		# the amount of tiles the attack will push. 0 if undefined
		var pushed_into_tile_index : Vector2 = tile_index
		if self.index_to_unit.has(tile_index):	# if unit exists to be pushed
			if push_scalar != 0:
				var push_direction : Vector2 = damage_pattern[tile_index]["direction"]
				if push_direction in self.directions:
					# unit will be moved as many times over in the attack direction as possible, counting collisions made and then pushing the unit where needed
					for i in range(push_scalar):
						var checking_index = pushed_into_tile_index + (self.directions[push_direction] * (sign(push_scalar)))
						if self.get_cell(checking_index.x, checking_index.y) != INVALID_CELL: 	# if cell is on the map
							if self.index_to_unit.has(checking_index):	# check collisions
								# set collision damage at original tile
								var collision_damage : int = abs(push_scalar) - abs(i)
								push_damage_pattern[tile_index]["damage"]["normal"] = push_damage_pattern[tile_index]["damage"].get("normal", 0) + collision_damage
								
								# other collision must be added as an entry to damage pattern if it doesn't exist
								push_damage_pattern[checking_index] = push_damage_pattern.get(checking_index, Dictionary())
								push_damage_pattern[checking_index]["direction"] = "none"
								push_damage_pattern[checking_index]["push_scalar"] = 0
								push_damage_pattern[checking_index]["damage"] = push_damage_pattern[checking_index].get("damage", Dictionary())
								push_damage_pattern[checking_index]["damage"]["normal"] = push_damage_pattern[checking_index]["damage"].get("normal", 0) + collision_damage
								break
							else:
								# no collision; move the unit instead
								pushed_into_tile_index = checking_index
								if tile_index != pushed_into_tile_index:
									push_damage_pattern[tile_index]["push_into_tile_index"] = pushed_into_tile_index
						else:
							break	# no need to continue if you hit the edge of the map
	return push_damage_pattern			
	
	

func generate_cardinal_pattern(tile_index : Vector2, size := 1, blockable := false, include_center = false):
	# generates a filtered attack pattern in the cardinals of length size
	# if blockable units and obstacles will stop it
	var attackable_tiles = Dictionary()
	
	if include_center:
		attackable_tiles[tile_index] = {"direction": "none"}
	
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
	
func generate_allied_pattern(attacking_unit, include_self = true):
	# generate pattern corresponding to all allied locations
	var attackable_tiles = Dictionary()
	
	for unit in self.unit_to_index:
		if unit.unit_team == attacking_unit.unit_team: 
			if unit != attacking_unit or include_self:
				var tile_index = self.unit_to_index[unit]
				attackable_tiles[tile_index] = {"direction": "none"}
		
	return attackable_tiles
	
func generate_enemy_pattern(attacking_unit):
	# generate pattern corresponding to all allied locations
	var attackable_tiles = Dictionary()
	
	for unit in self.unit_to_index:
		if unit.unit_team != attacking_unit.unit_team: 
			var tile_index = self.unit_to_index[unit]
			attackable_tiles[tile_index] = {"direction": "none"}
	
	return attackable_tiles
	

	