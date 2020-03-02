extends Node

signal change_scene


onready var overworld_location_asset = preload("res://scenes/overworld/OverworldLocation.tscn")
onready var overworld_route_line_asset = preload("res://scenes/overworld/OverworldRouteLine.tscn")
onready var overworld_region_asset = preload("res://scenes/overworld/OverworldRegion.tscn")

onready var day_count_label = $OverworldInfoModule/OverworldInfoDayLabel

onready var caravan_indicator = $CaravanSprite
onready var caravan_travel_tween = $CaravanSprite/CaravanTravelTween

onready var shop_screen_button = $ChangeSceneButtonShopScreen
onready var recruitment_screen_button = $ChangeSceneButtonRecruitmentScreen

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	caravan_travel_tween.connect("tween_completed", caravan_indicator, "_on_CaravanTravelTween_completed")
	
	# listeners
	relay.connect("caravan_started_traveling", self, "_on_caravan_started_traveling")
	relay.connect("caravan_destination_reached", self, "_on_caravan_destination_reached")

func init(game_data):
	#  create regions
	var region_data = root.game_data["region_data"]
	for region_id in root.game_data["region_data"]:
		var current_region_data = root.game_data["region_data"][region_id]
		var region = overworld_region_asset.instance()
		self.add_child(region)
		region.init(current_region_data)

	# create overworld locations
	var overworld_data = root.game_data["overworld_data"]
	for location_id in root.game_data["overworld_data"]:
		var current_overworld_data = root.game_data["overworld_data"][location_id]
		var pos = current_overworld_data["location_coords"]
		var overworld_location = self.overworld_location_asset.instance()
		var pivot_offset = overworld_location.rect_pivot_offset		# used to make the locations centered
		overworld_location.rect_position = Vector2(pos[0], pos[1])
		self.add_child(overworld_location)
		overworld_location.init(current_overworld_data)
		
		# create lines between locations
		for neighbor_id in current_overworld_data.get("location_neighbor_ids", []):
			if neighbor_id < location_id:	# prevents duplicate lines
				var neighbor_overworld_data = root.game_data["overworld_data"][neighbor_id]
				var neighbor_pos = neighbor_overworld_data["location_coords"]
				
				var map_route_line = overworld_route_line_asset.instance()
				self.add_child(map_route_line)
				
				map_route_line.add_point(Vector2(pos[0]+pivot_offset[0], pos[1]+pivot_offset[1]))
				map_route_line.add_point(Vector2(neighbor_pos[0]+pivot_offset[0], neighbor_pos[1]+pivot_offset[1]))
		
	# change text
	day_count_label.text = str(root.game_data["main_data"]["day"])
	
	# set caravan position
	caravan_indicator.initialize_caravan_position()
	
	# shop visibility
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	self.shop_screen_button.hide()
	if self.root.game_data["overworld_data"][current_location_id].has("location_shop_id"):
		self.shop_screen_button.show()
		
	# recruitment visibility
	self.recruitment_screen_button.hide()
	if len(self.root.game_data["overworld_data"][current_location_id]["location_recruitment_unit_ids"]) > 0:
		self.recruitment_screen_button.show()

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)

func _on_caravan_started_traveling(to_location_id):
	self.shop_screen_button.hide()
	self.recruitment_screen_button.hide()
	print("OverworldScreen: caravan traveling to ",to_location_id,"....")

func _on_caravan_destination_reached(to_location_id):
	print("OverworldScreen: caravan reached ",to_location_id)
	root.game_data["main_data"]["current_location_id"] = to_location_id
	var location_event_complete = self.root.game_data["overworld_data"][to_location_id]["location_event_complete"]
	print("OverworldScreen: current event completion at this location ",location_event_complete )
	# if location's event complete
	if !location_event_complete:
		print("OverworldScreen: starting event at location....")
		self.change_scene("event_screen")
	else:
		# location has shop
		if self.root.game_data["overworld_data"][to_location_id].has("location_shop_id"):
			self.shop_screen_button.show()
		# location has recruitment
		if len(self.root.game_data["overworld_data"][to_location_id]["location_recruitment_unit_ids"]) > 0:
			self.recruitment_screen_button.show()
