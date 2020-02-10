extends Node

signal change_scene
signal update_game_data

onready var party_grid = get_node("PartyMemberList/ScrollContainer/PartyGrid")
var party_member_ui = preload("res://scenes/party/UnitPartyUIElement.tscn")

var inventory_item_button_asset = preload("res://scenes/party/InventoryItemButton.tscn")

onready var inventory_item_container = $InventoryItems/InventoryItemScrollContainer/InventoryItemGridContainer
onready var party_inventory_item_container = $PartyMemberInfo/PartyMemberItemScrollContainer/PartyMemberItemGridContainer

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	pass

func init(game_data):
	populate_party_screen()
	populate_inventory_items()
	
func populate_party_screen():
	for unit_id in root.game_data["unit_data"]:
		var player_team = root.game_data["main_data"]["player_team"]
		var unit_team = root.game_data["unit_data"][unit_id]["unit_team"]
		if  player_team == unit_team:
			var ui_element = self.party_member_ui.instance()
			self.party_grid.add_child(ui_element)
			ui_element.init(root.game_data["unit_data"][unit_id])

func populate_inventory_items():
	# populat items from player inventory
	var player_inventory_items = self.root.game_data["main_data"]["player_items"]
	for item_id in player_inventory_items:
		var inventory_item_button = inventory_item_button_asset.instance()
		self.inventory_item_container.add_child(inventory_item_button)
		inventory_item_button.init(player_inventory_items[item_id], "take")

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)