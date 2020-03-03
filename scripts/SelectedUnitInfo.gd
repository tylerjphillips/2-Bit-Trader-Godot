extends Node2D

onready var background = get_node("UIBackground")
onready var class_label = get_node("UnitClassLabel")
onready var health_point_label = get_node("UnitHealthPointLabel")
onready var action_point_label = get_node("UnitMovementPointLabel")
onready var name_label = get_node("UnitNameLabel")
onready var xp_label = get_node("UnitXPLabel")
onready var level_label = get_node("UnitLevelLabel")

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("unit_selected", self, "_on_unit_selected")
	relay.connect("unit_deselected", self, "_on_unit_deselected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_unit_selected(unit):
	print("SelectedUnitInfo: "+ unit.unit_name + " selected")
	# update info labels with unit info
	class_label.text = unit.unit_class
	health_point_label.text = "Health: "+ str(unit.unit_health_points) + "/" + str(unit.unit_health_points_max)
	action_point_label.text = "AP: "+ str(unit.unit_movement_points) + "/" + str(unit.unit_movement_points_max)
	xp_label.text = "XP: " + str(unit.unit_xp) + "/" + str(unit.unit_xp_max)
	level_label.text = "Level " + str(unit.unit_level)
	name_label.text = unit.unit_name
	
	# set team background color
	background.modulate = unit.get_team_color()
	
	#
	get_tree().call_group("item buttons", "_on_unit_selected", unit)
	
	self.show()

func _on_unit_deselected(unit):
	print("SelectedUnitInfo: "+ unit.unit_name + " deselected")
	self.hide()