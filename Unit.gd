extends Area2D

# signals
signal click_unit
signal update_health

# ui indicators
var selection_cursor
var move_indicator
var team_indicator
var health_bar

# unit properties
		# movement
export (int) var unit_movement_points = 4 setget set_unit_movement_points, get_unit_movement_points
export (int) var unit_movement_points_max = 4 setget set_unit_movement_points_max, get_unit_movement_points_max
var unit_can_move : bool = true setget set_unit_can_move, get_unit_can_move
		# health
export (int) var unit_health_points = 4 setget set_unit_health_points, get_unit_health_points
export (int) var unit_health_points_max = 4 setget set_unit_health_points_max, get_unit_health_points_max
		# general
export var unit_class = "Archer"
export var unit_team = "blue"
export var unit_name = ""
		# weapons and gear
var unit_can_attack : bool = true setget set_unit_can_attack, get_unit_can_attack
var unit_weapon_data : Dictionary = {}	# contains info on weapons this unit has

var is_selected : bool = false # whether or not the unit is selected

# colors used for team indication
const colors = {
	"white":Color(1, 1, 1, 0.8),
	"red":Color(0.8, 0.0, 0.0, 0.8),
	"green":Color(0.0, 0.8, 0.2, 0.8),
	"blue":Color(0.2, 0.2, 0.8, 0.8),
	}

var health_container = preload("res://HealthContainer.tscn")

func _ready():
	add_to_group("units")

func init(unit_position : Vector2, unit_args: Dictionary):
	self.position = unit_position
	# unit args
	self.unit_name = unit_args.get("unit_name", "Default name")
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
	self.selection_cursor = get_node("SelectionCursor")
	self.move_indicator = get_node("MoveIndicator")
	self.team_indicator = get_node("TeamIndicator")
	self.selection_cursor.hide()
	
	# change colors on UI stuff
	team_indicator.modulate = colors[self.unit_team]
	selection_cursor.modulate = colors[self.unit_team]
	
	self.unit_can_move = false
	self.unit_can_attack = false

#func _input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton \
#	and event.button_index == BUTTON_LEFT \
#	and event.is_pressed():
#		self.on_click()

#func on_click():
#	emit_signal("click_unit", self)
	
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
		
func _on_unit_attack_tile(unit, tile_index):
	if unit == self:
		self.set_unit_can_attack(false)
		self.set_unit_can_move(false)
		print("Unit: attacking ", tile_index)

func _on_PlayerUnit_mouse_entered():
	self.health_bar.show()
	return
	print("Mouse Entered")

func _on_PlayerUnit_mouse_exited():
	if not self.is_selected:
		self.health_bar.hide()
	return
	print("Mouse Exited")
	
func set_unit_movement_points(value):
	unit_movement_points = value
func get_unit_movement_points():
	return unit_movement_points
func set_unit_movement_points_max(value):
	unit_movement_points_max = value
func get_unit_movement_points_max():
	return unit_movement_points_max
func set_unit_health_points(value):
	unit_health_points = value
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
		move_indicator.modulate = self.colors["white"]
		
func get_unit_can_move():
	return unit_can_move
	
func set_unit_can_attack(canAttack : bool):
	unit_can_attack = canAttack
		
func get_unit_can_attack():
	return unit_can_attack
	
func get_team_color():
	return self.colors[self.unit_team]