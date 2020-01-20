extends Node

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")

onready var overworld_location_asset = preload("res://scenes/OverworldLocation.tscn")
onready var overworld_route_line_asset = preload("res://scenes/OverworldRouteLine.tscn")
onready var overworld_region_asset = preload("res://scenes/OverworldRegion.tscn")

onready var day_count_label = $OverworldInfoModule/OverworldInfoDayLabel
onready var gold_count_label = $OverworldInfoModule/OverworldInfoGoldLabel
onready var caravan_indicator = $CaravanSprite

func _ready():
	pass

func init(game_data):
	#  create regions
	var region_data = root.game_data["region_data"]
	for region_id in root.game_data["region_data"]:
		var current_region_data = root.game_data["region_data"][region_id]
		var region = overworld_region_asset.instance()
		self.add_child(region)
		region.init(current_region_data)

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
				var neighbor_map_data = root.game_data["map_data"][neighbor_id]
				var neighbor_pos = neighbor_map_data["map_location_coords"]
				
				var map_route_line = overworld_route_line_asset.instance()
				self.add_child(map_route_line)
				
				map_route_line.add_point(Vector2(pos[0]+pivot_offset[0], pos[1]+pivot_offset[1]))
				map_route_line.add_point(Vector2(neighbor_pos[0]+pivot_offset[0], neighbor_pos[1]+pivot_offset[1]))
		
	# change text
	day_count_label.text = str(root.game_data["main_data"]["day"])
	gold_count_label.text = str(root.game_data["main_data"]["gold"])
	
	
	# move caravan indicator to the percentage between the two locations on the current route
	# indicated by the current event and number of events on the route
	var current_event_id = root.game_data["main_data"]["current_event_id"]
	var current_route_data = root.game_data["main_data"]["current_route"]
		# get positions of start and end overworld locations
	var from_location_id = current_route_data["from_map_id"]
	var to_location_id = current_route_data["to_map_id"]
	var from_pos = map_data[from_location_id]["map_location_coords"]
	var to_pos = map_data[to_location_id]["map_location_coords"]
	from_pos = Vector2(from_pos[0],from_pos[1])		# array->vector2
	to_pos = Vector2(to_pos[0],to_pos[1])
		# interpolate between them and set caravan location to it
	var route_percent_complete = float(current_route_data["route_event_ids"].find(current_event_id) + 1) / current_route_data["route_event_ids"].size()
	var interpolated_pos = from_pos + (to_pos - from_pos) * route_percent_complete
	caravan_indicator.position = interpolated_pos

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)