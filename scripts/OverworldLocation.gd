extends TextureButton

onready var location_crosshar = get_node("OverworldLocationCrosshair")
onready var location_name_label = get_node("OverworldLocationName")
onready var location_icon = get_node("OverworldLocationIcon")

signal change_scene

onready var root = get_tree().get_root().get_node("Root")

var map_id;

func _ready():
	pass

func init(map_data):
	self.map_id = map_data["map_id"]
	location_name_label.text = map_data["map_name"]
	location_icon.frame = randi() % 6 # randomize the image
	

func _on_OverworldLocation_button_up():
	self.root.game_data["main_data"]["current_map_id"] = map_id
	emit_signal("change_scene", "combat_screen")
