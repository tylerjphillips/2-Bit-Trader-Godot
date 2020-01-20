extends TextureButton

onready var location_crosshar = get_node("OverworldLocationCrosshair")
onready var location_name_label = get_node("OverworldLocationName")
onready var location_icon = get_node("OverworldLocationIcon")

signal overworld_location_button_up

onready var root = get_tree().get_root().get_node("Root")

var map_id;

func _ready():
	pass

func init(map_data):
	self.map_id = map_data["map_id"]
	location_name_label.text = map_data["map_name"]
	location_icon.frame = randi() % 6 # randomize the image
	

func _on_OverworldLocation_button_up():
	emit_signal("overworld_location_button_up", self.map_id)
