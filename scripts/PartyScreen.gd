extends Node

signal change_scene
signal update_game_data

onready var party_grid = get_node("ScrollContainer/PartyGrid")
var party_member_ui = preload("res://scenes/UnitPartyUIElement.tscn")

func _ready():
	pass

func init(game_data):
	populate_party_screen(game_data)
	
func populate_party_screen(game_data):
	for unit_id in game_data["unit_data"]:
		var ui_element = self.party_member_ui.instance()
		self.party_grid.add_child(ui_element)
		ui_element.init(game_data["unit_data"][unit_id])

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)