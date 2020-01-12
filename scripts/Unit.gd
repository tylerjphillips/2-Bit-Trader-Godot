extends Area2D

# signals
signal click_unit
signal update_health # (unit_health_points, unit_health_points_max)
signal kill_unit # (unit)

# ui indicators
var health_bar
onready var selection_cursor = get_node("SelectionCursor")
onready var move_indicator = get_node("MoveIndicator")
onready var team_indicator = get_node("TeamIndicator")

# unit properties
		# movement
export (int) var unit_movement_points = 4 setget set_unit_movement_points, get_unit_movement_points
export (int) var unit_movement_points_max = 4 setget set_unit_movement_points_max, get_unit_movement_points_max
var unit_can_move : bool = true setget set_unit_can_move, get_unit_can_move
		# position
var unit_tile_index : Vector2	 setget set_unit_tile_index, get_unit_tile_index # Unit does not directly change tile index, must be handled by tilemap. Stored in unit for serialization purposes
		# health
export (int) var unit_health_points = 4 setget set_unit_health_points, get_unit_health_points
export (int) var unit_health_points_max = 4 setget set_unit_health_points_max, get_unit_health_points_max
		# general
export var unit_class = "Archer"
export var unit_team = "blue"
export var unit_name = ""
export var unit_id = "" # used to uniquely identify unit for (de)serialization and scene changes. unix epoch of when unit is generated
		# attacking, weapons, and gear
var unit_can_attack : bool = true setget set_unit_can_attack, get_unit_can_attack
var unit_weapon_data : Dictionary = {}	# contains info on weapons this unit has

var is_selected : bool = false # whether or not the unit is selected

var health_container = preload("res://scenes/HealthContainer.tscn")

onready var root = get_tree().get_root().get_node("Root")	# reference to root game node

func _ready():
	add_to_group("units")
	self.connect("kill_unit", self, "_on_kill_unit")

func init(unit_position : Vector2, unit_args: Dictionary):
	# position and tile index (mandatory)
	self.position = unit_position	# world position not tile index
	self.unit_tile_index = Vector2(unit_args["unit_tile_index"][0], unit_args["unit_tile_index"][1])
	# unit args
	self.unit_name = unit_args.get("unit_name", "Default name")
	self.unit_id = unit_args.get("unit_id", str(OS.get_unix_time()))
	self.unit_team = unit_args.get("unit_team", "red")
	self.unit_movement_points = unit_args.get("unit_movement_points", 4)
	self.unit_movement_points_max = unit_args.get("unit_movement_points_max", 4)
	
	self.unit_health_points = unit_args.get("unit_health_points", 1)
	self.unit_health_points_max = unit_args.get("unit_health_points_max", 1)
	self.unit_class = unit_args.get("unit_class", "Archer")
	self.unit_weapon_data = unit_args.get("unit_weapon_data", {})
	
	# initialize health bar
	self.health_bar = health_container.instance()
	self.add_child(self.health_bar)
	self.health_bar.init(unit_health_points,unit_health_points_max)
	self.connect("update_health", self.health_bar, "_on_update_health")	
	self.health_bar.hide()
	
	# UI indicators
	self.selection_cursor.hide()
	
	# change colors on UI stuff
	team_indicator.modulate = self.root.colors[self.unit_team]
	selection_cursor.modulate = self.root.colors[self.unit_team]
	
	self.unit_can_move = unit_args.get("unit_can_move", true)
	self.unit_can_attack = unit_args.get("unit_can_attack", true)

func damage_unit(weapon_data):
	if weapon_data["damage"].has("normal"):
		self.unit_health_points -= weapon_data["damage"]["normal"]

func _on_unit_selected(unit):
	is_selected = false
	self.health_bar.hide()
	if unit == self:
		is_selected = true
		self.health_bar.show()
		self.selection_cursor.show()
		
func _on_unit_deselected(unit):
	is_selected = false
	self.health_bar.hide()
	self.selection_cursor.hide()

func _on_start_team_turn(team):
	if self.unit_team == team:
		self.unit_can_move = true
		self.unit_can_attack = true

func _on_end_team_turn(team):
	if self.unit_team == team:
		self.unit_can_move = false
		self.unit_can_attack = false
		
func _on_unit_moved(unit, tile_index, movement_cost):
	if unit == self:
		self.set_unit_can_move(false)
		self.unit_tile_index = tile_index
		
func _on_unit_attacks_unit(attacking_unit, weapon_data, attacked_unit):
	if attacking_unit == self:
		print("Unit: attacking ", attacked_unit.unit_name)
	elif attacked_unit == self:
		self.damage_unit(weapon_data)
		
func _on_unit_collides_unit(attacking_unit, affected_unit, collision_count, collided_unit):
	if affected_unit == self or collided_unit == self:
		var collision_damage = {"damage": { "normal": collision_count}}
		
		print("Unit: ", affected_unit.unit_name, " collides with ", collided_unit.unit_name)
		self.damage_unit(collision_damage)

func _on_PlayerUnit_mouse_entered():
	self.health_bar.show()
	return
	print("Mouse Entered")

func _on_PlayerUnit_mouse_exited():
	if not self.is_selected:
		self.health_bar.hide()
	return
	print("Mouse Exited")
	
func _on_kill_unit(unit):
	if unit ==  self:
		self.erase_global_data_entry()
	
func set_unit_movement_points(value):
	unit_movement_points = value
func get_unit_movement_points():
	return unit_movement_points
func set_unit_movement_points_max(value):
	unit_movement_points_max = value
func get_unit_movement_points_max():
	return unit_movement_points_max
func set_unit_tile_index(value):
	unit_tile_index = value
func get_unit_tile_index():
	return unit_tile_index
func set_unit_health_points(value):
	unit_health_points = value
	if self.unit_health_points <= 0:
		emit_signal("kill_unit", self)
	else:
		emit_signal("update_health", unit_health_points, unit_health_points_max)
func get_unit_health_points():
	return unit_health_points
func set_unit_health_points_max(value):
	unit_health_points_max = value
func get_unit_health_points_max():
	return unit_health_points_max

func set_unit_can_move(canMove : bool):
	unit_can_move = canMove
	if unit_can_move:
		move_indicator.modulate = self.get_team_color()
	else:
		move_indicator.modulate = self.root.colors["white"]
		
func get_unit_can_move():
	return unit_can_move
	
func set_unit_can_attack(canAttack : bool):
	unit_can_attack = canAttack
		
func get_unit_can_attack():
	return unit_can_attack
	
func get_team_color():
	return self.root.colors[self.unit_team]

###### Serialization and global data management #####

func update_global_data_entry():
	# updates the game data at the root
	self.root.game_data["unit_data"][self.unit_id] = self.get_unit_repr()
	
func erase_global_data_entry():
	# removes entry from global game data at root
	print("Unit: killed, data erased")
	self.root.game_data["unit_data"].erase(self.unit_id)

func get_unit_repr():
	# returns dictionary containing all data for this unit
	var unit_data = Dictionary();
	unit_data["unit_name"] = self.unit_name
	unit_data["unit_id"] = self.unit_id
	unit_data["unit_team"] = self.unit_team
	unit_data["unit_movement_points"] = self.unit_movement_points
	unit_data["unit_movement_points_max"] = self.unit_movement_points_max
	unit_data["unit_tile_index"] = self.unit_tile_index
	unit_data["unit_health_points"] = self.unit_health_points
	unit_data["unit_health_points_max"] = self.unit_health_points_max
	unit_data["unit_class"] = self.unit_class
	unit_data["unit_weapon_data"] = self.unit_weapon_data
	unit_data["unit_can_move"] = self.unit_can_move
	unit_data["unit_can_attack"] = self.unit_can_attack
	
	return unit_data;