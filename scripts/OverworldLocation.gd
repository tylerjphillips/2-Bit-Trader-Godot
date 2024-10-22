extends TextureButton

onready var location_crosshar = get_node("OverworldLocationCrosshair")
onready var location_name_label = get_node("OverworldLocationName")
onready var location_icon = get_node("OverworldLocationIcon")

signal overworld_location_button_up # (location_id)

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

var location_id;

func _ready():
	# emitters
	self.connect("overworld_location_button_up", relay, "_on_overworld_location_button_up")

func init(overworld_data):
	self.location_id = overworld_data["location_id"]
	location_name_label.text = overworld_data["location_name"]
	location_icon.frame = randi() % 6 # randomize the image
	

func _on_OverworldLocation_button_up():
	emit_signal("overworld_location_button_up", self.location_id)
