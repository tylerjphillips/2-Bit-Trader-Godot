extends Node

signal change_scene # (old_scene_name, new_scene_name)

signal day_ended
signal gold_amount_changed

onready var overworld_location_asset = preload("res://scenes/overworld/OverworldLocation.tscn")
onready var overworld_route_line_asset = preload("res://scenes/overworld/OverworldRouteLine.tscn")
onready var overworld_region_asset = preload("res://scenes/overworld/OverworldRegion.tscn")

onready var caravan_indicator = $CaravanSprite
onready var caravan_travel_tween = $CaravanSprite/CaravanTravelTween

onready var actions_container = $ActionsContainer
onready var shop_screen_button = $ActionsContainer/ChangeSceneButtonShopScreen
onready var recruitment_screen_button = $ActionsContainer/ChangeSceneButtonRecruitmentScreen
onready var rest_party_button = $ActionsContainer/RestPartyButton

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	caravan_travel_tween.connect("tween_completed", caravan_indicator, "_on_CaravanTravelTween_completed")
	
	# emitters
	self.connect("day_ended", relay, "_on_day_ended")
	self.connect("gold_amount_changed", relay, "_on_gold_amount_changed")
	self.connect("change_scene", relay, "_on_change_scene")
	
	# listeners
	relay.connect("caravan_started_traveling", self, "_on_caravan_started_traveling")
	relay.connect("caravan_destination_reached", self, "_on_caravan_destination_reached")
	relay.connect("overworld_rest_button_up", self, "_on_overworld_rest_button_up")

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
		
	# location has resting
	self.rest_party_button.hide()
	if self.root.game_data["overworld_data"][current_location_id]["location_can_rest"]:
		self.rest_party_button.show()

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)

func _on_caravan_started_traveling(to_location_id):
	self.actions_container.hide()
	print("OverworldScreen: caravan traveling to ",to_location_id,"....")

func _on_caravan_destination_reached(to_location_id):
	print("OverworldScreen: caravan reached ",to_location_id)
	self.actions_container.show()
	self.increment_day()
	self.subtract_upkeep_costs()
	
	root.game_data["main_data"]["current_location_id"] = to_location_id
	var location_event_complete = self.root.game_data["overworld_data"][to_location_id]["location_event_complete"]
	print("OverworldScreen: current event completion at this location ",location_event_complete )
	# if location's event not complete
	if !location_event_complete:
		print("OverworldScreen: starting event at location....")
		# set the current event to location's event
		root.game_data["main_data"]["current_event_id"] = self.root.game_data["overworld_data"][to_location_id]["event_id"]
		self.change_scene("event_screen")
	else:
		# location has shop
		self.shop_screen_button.hide()
		if self.root.game_data["overworld_data"][to_location_id].has("location_shop_id"):
			self.shop_screen_button.show()
		# location has recruitment
		self.recruitment_screen_button.hide()
		if len(self.root.game_data["overworld_data"][to_location_id]["location_recruitment_unit_ids"]) > 0:
			self.recruitment_screen_button.show()
		# location has resting
		self.rest_party_button.hide()
		if self.root.game_data["overworld_data"][to_location_id]["location_can_rest"]:
			self.rest_party_button.show()

func _on_overworld_rest_button_up():
	self.increment_day()
	self.heal_player_party()
	self.rest_party_button.hide()
	
func heal_player_party():
	var party_unit_ids = self.root.game_data["main_data"]["party_unit_ids"]
	for party_unit_id in party_unit_ids:
		self.root.game_data["unit_data"][party_unit_id]["unit_health_points"] = self.root.game_data["unit_data"][party_unit_id]["unit_health_points_max"]

func increment_day():
	var day = self.root.game_data["main_data"]["day"] + 1
	self.root.game_data["main_data"]["day"] += 1
	var days_until_defeat = self.root.game_data["main_data"]["days_until_defeat"]
	if (days_until_defeat != -1) and (day > days_until_defeat):
		emit_signal("change_scene", "overworld_screen", "game_over_screen")
		
	emit_signal("day_ended")
	
func subtract_upkeep_costs():
	# remove upkeep from the player
	var party_unit_ids = self.root.game_data["main_data"]["party_unit_ids"]
	var gold = self.root.game_data["main_data"]["gold"]
	for unit_id in party_unit_ids:
		var unit_upkeep_cost = self.root.game_data["unit_data"][unit_id]["unit_upkeep_cost"]
		gold -= unit_upkeep_cost
	self.root.game_data["main_data"]["gold"] = gold
	emit_signal("gold_amount_changed")


