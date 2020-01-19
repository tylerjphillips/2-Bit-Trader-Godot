extends Node

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")

onready var overworld_location_asset = preload("res://scenes/OverworldLocation.tscn")
onready var overworld_route_line_asset = preload("res://scenes/OverworldRouteLine.tscn")

onready var day_count_label = $OverworldInfoModule/OverworldInfoDayLabel
onready var gold_count_label = $OverworldInfoModule/OverworldInfoGoldLabel

func _ready():
	pass

func init(game_data):
	# create overworld locations
	var map_data = root.game_data["map_data"]
	for map_id in root.game_data["map_data"]:
		var current_map_data = root.game_data["map_data"][map_id]
		var pos = current_map_data["map_location_coords"]
		var overworld_location = self.overworld_location_asset.instance()
		var pivot_offset = overworld_location.rect_pivot_offset		# used to make the locations centered
		overworld_location.rect_position = Vector2(pos[0], pos[1])
		self.add_child(overworld_location)
		overworld_location.init(current_map_data)
		
		overworld_location.connect("change_scene", self, "change_scene")
		
		# create lines between locations
		for neighbor_id in current_map_data.get("map_neighbor_ids", []):
			if neighbor_id < map_id:	# prevents duplicate lines
				print("OverworldScreen: Creating line!!!!")
				var neighbor_map_data = root.game_data["map_data"][neighbor_id]
				var neighbor_pos = neighbor_map_data["map_location_coords"]
				
				var map_route_line = overworld_route_line_asset.instance()
				self.add_child(map_route_line)
				
				map_route_line.add_point(Vector2(pos[0]+pivot_offset[0], pos[1]+pivot_offset[1]))
				map_route_line.add_point(Vector2(neighbor_pos[0]+pivot_offset[0], neighbor_pos[1]+pivot_offset[1]))
				print(map_route_line.points)
		
	# change text
	day_count_label.text = str(root.game_data["main_data"]["day"])
	gold_count_label.text = str(root.game_data["main_data"]["gold"])
		

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)