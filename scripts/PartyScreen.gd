extends Node

signal change_scene
signal update_game_data

onready var party_grid = get_node("ScrollContainer/PartyGrid")
var party_member_ui = preload("res://scenes/party/UnitPartyUIElement.tscn")

onready var root = get_tree().get_root().get_node("Root")

func _ready():
	pass

func init(game_data):
	populate_party_screen()
	
func populate_party_screen():
	for unit_id in root.game_data["unit_data"]:
		var player_team = root.game_data["main_data"]["player_team"]
		var unit_team = root.game_data["unit_data"][unit_id]["unit_team"]
		if  player_team == unit_team:
			var ui_element = self.party_member_ui.instance()
			self.party_grid.add_child(ui_element)
			ui_element.init(root.game_data["unit_data"][unit_id])

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)