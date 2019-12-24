extends Area2D

signal click_unit
signal update_health

export (int) var unit_movement_points = 4 setget set_unit_movement_points, get_unit_movement_points
export (int) var unit_movement_points_max = 4 setget set_unit_movement_points_max, get_unit_movement_points_max
export (int) var unit_health_points = 4 setget set_unit_health_points, get_unit_health_points
export (int) var unit_health_points_max = 4 setget set_unit_health_points_max, get_unit_health_points_max
export var unit_class = "Archer"
export var unit_team = "blue"
export var unit_name = ""

const colors = {"red":Color(0.8, 0.0, 0.0, 0.8),
	"green":Color(0.0, 0.8, 0.8, 0.8),
	"blue":Color(0.2, 0.2, 0.8, 0.8),}

var health_bar
var is_selected = false # whether or not the unit is selected

var health_container = preload("res://HealthContainer.tscn")

func _ready():
	add_to_group("units")

func init(unit_position : Vector2, unit_args: Dictionary):
	self.position = unit_position
	# unit args
	self.unit_name = unit_args.get("unit_name", "Default name")
	self.unit_team = unit_args.get("unit_team", "red")
	self.unit_health_points = unit_args.get("unit_health_points", 1)
	self.unit_health_points_max = unit_args.get("unit_health_points_max", 1)
	self.unit_class = unit_args.get("unit_class", "Archer")
	
	# initialize health bar
	self.health_bar = health_container.instance()
	self.add_child(self.health_bar)
	self.health_bar.init(unit_health_points,unit_health_points_max)
	self.connect("update_health", self.health_bar, "_on_update_health")	
	self.health_bar.hide()
	
	# team indicator
	$TeamIndicator.modulate = colors[self.unit_team]

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	emit_signal("click_unit", self)
	
func _on_unit_selected(unit):
	is_selected = false
	self.health_bar.hide()
	if unit == self:
		is_selected = true
		self.health_bar.show()
		
func _on_unit_deselected(unit):
	is_selected = false
	self.health_bar.hide()

func _on_start_team_turn(team):
	if self.unit_team == team:
		print(unit_name + " turn started")

func _on_end_team_turn(team):
	if self.unit_team == team:
		print(unit_name + " turn ended")

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
	
func get_team_color():
	return self.colors[self.unit_team]