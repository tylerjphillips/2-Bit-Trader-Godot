extends Node

signal change_scene
signal update_game_data

signal end_of_route		# (to_map_id)
signal start_of_route	# (from_map_id, to_map_id)

onready var root = get_tree().get_root().get_node("Root")

onready var overworld_location_asset = preload("res://scenes/OverworldLocation.tscn")
onready var overworld_route_line_asset = preload("res://scenes/OverworldRouteLine.tscn")
onready var overworld_region_asset = preload("res://scenes/OverworldRegion.tscn")

onready var day_count_label = $OverworldInfoModule/OverworldInfoDayLabel
onready var gold_count_label = $OverworldInfoModule/OverworldInfoGoldLabel
onready var caravan_indicator = $CaravanSprite
onready var continue_route_button = $ContinueRouteButton

func _ready():
	continue_route_button.connect("button_up", self, "continue_along_route")

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
		
		overworld_location.connect("overworld_location_button_up", self, "_on_overworld_location_button_up")
		
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
	
	self.calculate_caravan_position()

func calculate_caravan_position():
	# move caravan indicator to the percentage between the two locations on the current route
	# indicated by the current event and number of events on the route
	var map_data = root.game_data["map_data"]
	var current_event_id = root.game_data["main_data"]["current_event_id"]
	var current_route_data = root.game_data["main_data"]["current_route"]

	var from_location_id = current_route_data["from_map_id"]
	var from_pos = map_data[from_location_id]["map_location_coords"]
	from_pos = Vector2(from_pos[0],from_pos[1])		# array->vector2	
	if !current_route_data["has_route_selected"]:
		# if no route selected just use "from" location
		caravan_indicator.position = from_pos
	else:
		# interpolate between them and set caravan location to it
		var to_location_id = current_route_data["to_map_id"]
		var to_pos = map_data[to_location_id]["map_location_coords"]
		to_pos = Vector2(to_pos[0],to_pos[1])
		var route_percent_complete = float(current_route_data["route_event_ids"].find(current_event_id) + 1) / current_route_data["route_event_ids"].size()
		var interpolated_pos = from_pos + (to_pos - from_pos) * route_percent_complete
		caravan_indicator.position = interpolated_pos

func continue_along_route():
	# Moves caravan to the next event in the overworld route
	var current_route_data = root.game_data["main_data"]["current_route"]
	if current_route_data["has_route_selected"]:
		var map_data = root.game_data["map_data"]
		var current_event_id = root.game_data["main_data"]["current_event_id"]
		var current_route_events : Array = root.game_data["main_data"]["current_route"]["route_event_ids"]
		var event_index = current_route_events.find(current_event_id)
		assert event_index != -1
		event_index += 1
		if event_index >= current_route_events.size():
			var to_map_id = current_route_data["to_map_id"]
			self.end_route(to_map_id)
		else:
			root.game_data["main_data"]["current_event_id"] = current_route_events[event_index]
		calculate_caravan_position()
	else:
		print("OverworldScreen: no route selected")
		
func end_route(to_map_id):
	print("OverworldScreen: End of route: ", to_map_id, " reached")
	emit_signal("end_of_route", to_map_id)
	root.game_data["main_data"]["current_route"]["has_route_selected"] = false
	root.game_data["main_data"]["current_route"]["from_map_id"] = to_map_id	# destination becomes current location
	root.game_data["main_data"]["current_route"]["to_map_id"] = null
	calculate_caravan_position()
	
func start_route(from_map_id, to_map_id):
	print("OverworldScreen: route started from ", from_map_id, " to ", to_map_id)
	emit_signal("start_of_route",from_map_id, to_map_id)
	
	self.populate_route_event_list()
	# reset route info
	root.game_data["main_data"]["current_route"]["has_route_selected"] = true
	root.game_data["main_data"]["current_route"]["from_map_id"] = from_map_id
	root.game_data["main_data"]["current_route"]["to_map_id"] = to_map_id
	calculate_caravan_position()

func populate_route_event_list():
	# TODO change this later
	root.game_data["main_data"]["current_event_id"] = root.game_data["main_data"]["current_route"]["route_event_ids"][0]

func _on_overworld_location_button_up(to_map_id):
	# selects an location to travel to if one isn't selected 
	var current_route_data = root.game_data["main_data"]["current_route"]
	if !current_route_data["has_route_selected"]:
		# can't travel to a location you're already at
		var from_map_id = root.game_data["main_data"]["current_route"]["from_map_id"]
		if from_map_id != to_map_id:
			start_route(from_map_id, to_map_id)
	else:
		print("OverworldScreen: location ", root.game_data["main_data"]["current_route"]["to_map_id"], " already selected!")

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)