extends Node

onready var recruit_grid = get_node("ScrollContainer/RecruitmentGridContainer")
var party_member_ui = preload("res://scenes/UnitPartyUIElement.tscn")

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
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

func _on_party_member_button_pressed(button, unit_data):
	print("RecruitScreen: ", unit_data)