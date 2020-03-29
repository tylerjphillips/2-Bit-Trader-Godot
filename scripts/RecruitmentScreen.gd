extends Node

onready var title_screen_button = $ChangeSceneButtonTitleScreen

onready var recruit_grid = get_node("ScrollContainer/RecruitmentGridContainer")
var party_member_ui = preload("res://scenes/UnitPartyUIElement.tscn")

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

signal unit_recruitment_failed(unit_data)
signal unit_recruitment_succeeded(unit_data)

signal change_scene # (old_scene_name, new_scene_name)

func _ready():
	title_screen_button.connect("change_scene", self, "change_scene")
	# emitters
	self.connect("change_scene", relay, "_on_change_scene")
	self.connect("unit_recruitment_failed", relay, "_on_unit_recruitment_failed")
	self.connect("unit_recruitment_succeeded", relay, "_on_unit_recruitment_succeeded")
	# listeners	
	relay.connect("party_member_button_pressed", self, "_on_party_member_button_pressed")

func init(game_data):
	populate_recruitment_screen()

func populate_recruitment_screen():
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	var location_recruitment_unit_ids = root.game_data["overworld_data"][current_location_id]["location_recruitment_unit_ids"]
	for unit_id in location_recruitment_unit_ids:
		var ui_element = self.party_member_ui.instance()
		self.recruit_grid.add_child(ui_element)
		var x = root.game_data["unit_data"]
		ui_element.init(root.game_data["unit_data"][unit_id])

func _on_party_member_button_pressed(recruit_button, unit_data):
	# attempt recruitment
	var player_gold = root.game_data["main_data"]["gold"]
	var recruitment_cost = unit_data["unit_recruitment_cost"]
	var unit_id = unit_data["unit_id"]
	if player_gold >= recruitment_cost:
		emit_signal("unit_recruitment_succeeded", unit_data)
		# remove gold
		root.game_data["main_data"]["gold"] -= recruitment_cost
		# remove from location
		var current_location_id = root.game_data["main_data"]["current_location_id"]
		root.game_data["overworld_data"][current_location_id]["location_recruitment_unit_ids"].erase(unit_id)
		# add to party
		self.root.game_data["main_data"]["party_unit_ids"].append(unit_id)
		# remove recruitment button
		recruit_button.queue_free()
	else:
		emit_signal("unit_recruitment_failed", unit_data)
		
func change_scene(new_scene_name):
	emit_signal("change_scene", "recruitment_screen", new_scene_name)