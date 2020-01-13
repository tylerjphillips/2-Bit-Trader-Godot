extends TextureButton

onready var location_crosshar = get_node("OverworldLocationCrosshair")
onready var location_name_label = get_node("OverworldLocationName")

var map_id;

func _ready():
	pass

func init(map_data):
	self.map_id = map_data["map_id"]
	location_name_label.text = map_data["map_name"]
	

func _on_OverworldLocation_button_up():
	pass
