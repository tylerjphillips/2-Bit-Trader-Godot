extends Node2D

onready var background = get_node("UIBackground")
onready var class_label = get_node("UnitClassLabel")
onready var health_point_label = get_node("UnitHealthPointLabel")
onready var action_point_label = get_node("UnitMovementPointLabel")
onready var name_label = get_node("UnitNameLabel")

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_unit_selected(unit):
	print("SelectedUnitInfo: "+ unit.unit_name + " selected")

	class_label.text = unit.unit_class
	health_point_label.text = "Health: "+ str(unit.unit_health_points) + "/" + str(unit.unit_health_points_max)
	action_point_label.text = "AP: "+ str(unit.unit_movement_points) + "/" + str(unit.unit_movement_points_max)
	name_label.text = unit.unit_name
	
	background.modulate = unit.get_team_color()
	self.show()

func _on_unit_deselected(unit):
	print("SelectedUnitInfo: "+ unit.unit_name + " deselected")
	self.hide()