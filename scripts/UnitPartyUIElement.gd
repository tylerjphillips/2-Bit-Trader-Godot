extends Control

# unit data stored as a dictionary. Less efficient to uniquely store every unit variable
var unit_data : Dictionary

# child nodes
onready var background = get_node("UnitPartyBackground")
onready var class_label = get_node("UnitPartyClassLabel")
onready var health_point_label = get_node("UnitPartyHealthPointLabel")
onready var action_point_label = get_node("UnitPartyAPLabel")
onready var name_label = get_node("UnitPartyNameLabel")
onready var unit_avatar = get_node("UnitPartyAvatar")

onready var root = get_tree().get_root().get_node("Root")	# reference to root game node

func _ready():
	pass
	
func init(unit_args):
	print("PartyUIElement: init")
	self.unit_data = unit_args
	
	# update labels
	class_label.text = self.unit_data["unit_class"]
	health_point_label.text = "Health: "+ str(self.unit_data["unit_health_points"]) + "/" + str(self.unit_data["unit_health_points_max"])
	action_point_label.text = "AP: "+ str(self.unit_data["unit_movement_points"]) + "/" + str(self.unit_data["unit_movement_points_max"])
	name_label.text = self.unit_data["unit_name"]
	
	# color background
	var unit_team = unit_args["unit_team"]
	self.background.modulate = self.root.colors[unit_team]