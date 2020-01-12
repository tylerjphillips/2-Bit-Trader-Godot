extends Control

var unit_data : Dictionary

var background
var class_label
var health_point_label
var action_point_label
var name_label
var unit_avatar

func _ready():
	pass
	
func init(unit_args):
	print("PartyUIElement: init")
	self.unit_data = unit_args
	
	self.background = get_node("UnitPartyBackground")
	self.class_label = get_node("UnitPartyClassLabel")
	self.health_point_label = get_node("UnitPartyHealthPointLabel")
	self.action_point_label = get_node("UnitPartyAPLabel")
	self.name_label = get_node("UnitPartyNameLabel")
	self.unit_avatar = get_node("UnitPartyAvatar")
	
	class_label.text = self.unit_data["unit_class"]
	health_point_label.text = "Health: "+ str(self.unit_data["unit_health_points"]) + "/" + str(self.unit_data["unit_health_points_max"])
	action_point_label.text = "AP: "+ str(self.unit_data["unit_movement_points"]) + "/" + str(self.unit_data["unit_movement_points_max"])
	name_label.text = self.unit_data["unit_name"]