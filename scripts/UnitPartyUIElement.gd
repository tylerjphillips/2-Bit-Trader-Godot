extends TextureButton

# unit data stored as a dictionary. Less efficient to uniquely store every unit variable
var unit_data : Dictionary

# child nodes
onready var background = get_node("UnitPartyBackground")
onready var class_label = get_node("UnitPartyClassLabel")
onready var health_point_label = get_node("UnitPartyHealthPointLabel")
onready var action_point_label = get_node("UnitPartyAPLabel")
onready var name_label = get_node("UnitPartyNameLabel")
onready var unit_avatar = get_node("UnitPartyAvatar")

signal party_member_button_pressed # (unit_data)

onready var root = get_tree().get_root().get_node("Root")	# reference to root game node
onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "_on_button_pressed")
	# emitters
	self.connect("party_member_button_pressed", relay, "_on_party_member_button_pressed")
	
func init(unit_args):
	self.unit_data = unit_args
	
	# update labels
	class_label.text = self.unit_data["unit_class"]
	health_point_label.text = "Health: "+ str(self.unit_data["unit_health_points"]) + "/" + str(self.unit_data["unit_health_points_max"])
	action_point_label.text = "AP: "+ str(self.unit_data["unit_movement_points"]) + "/" + str(self.unit_data["unit_movement_points_max"])
	name_label.text = self.unit_data["unit_name"]
	
	# color background
	var unit_team = unit_args["unit_team"]
	self.self_modulate = self.root.colors[unit_team]
	
func _on_button_pressed():
	emit_signal("party_member_button_pressed", unit_data)