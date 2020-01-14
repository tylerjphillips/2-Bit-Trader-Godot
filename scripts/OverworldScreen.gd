extends Node

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")

onready var overworld_location_asset = preload("res://scenes/OverworldLocation.tscn")

onready var day_count_label = $OverworldInfoModule/OverworldInfoDayLabel
onready var gold_count_label = $OverworldInfoModule/OverworldInfoGoldLabel

func _ready():
	pass

func init(game_data):
	# create overworld locations
	for map_id in root.game_data["map_data"]:
		var map_data = root.game_data["map_data"][map_id]
		var pos = map_data["map_location_coords"]
		var overworld_location = self.overworld_location_asset.instance()
		overworld_location.rect_position = Vector2(pos[0], pos[1])
		self.add_child(overworld_location)
		overworld_location.init(map_data)
		
		overworld_location.connect("change_scene", self, "change_scene")
		
	# change text
	day_count_label.text = str(root.game_data["main_data"]["day"])
	gold_count_label.text = str(root.game_data["main_data"]["gold"])
		

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)