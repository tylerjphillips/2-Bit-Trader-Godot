extends Node

signal change_scene # (old_scene_name, new_scene_name)

var selected_unit_data

onready var party_grid = get_node("PartyMemberList/ScrollContainer/PartyGrid")
var party_member_ui = preload("res://scenes/UnitPartyUIElement.tscn")

var inventory_item_button_asset = preload("res://scenes/party/InventoryItemButton.tscn")

# item containers
onready var inventory_item_container = $InventoryItems/InventoryItemScrollContainer/InventoryItemGridContainer
onready var party_inventory_item_container = $PartyMemberInfo/PartyMemberItemScrollContainer/PartyMemberItemGridContainer

# party member and inventory parents
onready var party_member_info = $PartyMemberInfo
onready var inventory_items = $InventoryItems

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	# emitters
	self.connect("change_scene", relay, "_on_change_scene")
	# listeners
	relay.connect("party_member_button_pressed", self, "_on_party_member_button_pressed")
	relay.connect("party_take_item_button_up", self, "_on_party_take_item_button_up")
	relay.connect("party_give_item_button_up", self, "_on_party_give_item_button_up")
	relay.connect("award_bonus_xp_button_up", self, "_on_award_bonus_xp_button_up")

func init(game_data):
	populate_party_screen()
	populate_inventory_items()

func clear_party_screen():
	self.selected_unit_data = null
	for party_member in self.party_grid.get_children():
		party_member.queue_free()

func populate_party_screen():
	self.clear_party_screen()
	for unit_id in root.game_data["main_data"]["party_unit_ids"]:
		var player_team = root.game_data["main_data"]["player_team"]
		var unit_team = root.game_data["unit_data"][unit_id]["unit_team"]
		if  player_team == unit_team:
			var ui_element = self.party_member_ui.instance()
			self.party_grid.add_child(ui_element)
			ui_element.init(root.game_data["unit_data"][unit_id])

func populate_inventory_items():
	self.clear_inventory_items()
	# populate items from player inventory
	var player_inventory_items = self.root.game_data["main_data"]["player_items"]
	for item_id in player_inventory_items:
		var inventory_item_button = inventory_item_button_asset.instance()
		self.inventory_item_container.add_child(inventory_item_button)
		inventory_item_button.init(player_inventory_items[item_id], "take")


func _on_party_member_button_pressed(button, selected_unit_data):
	self.selected_unit_data = selected_unit_data
	
	# show modules on the first party member selected
	party_member_info.show()
	inventory_items.show()
	
	populate_member_inventory_items()
	
	
func clear_party_member_items():
	for item_button in self.party_inventory_item_container.get_children():
		item_button.queue_free()
		
func clear_inventory_items():
	for item_button in self.inventory_item_container.get_children():
		item_button.queue_free()

func populate_member_inventory_items():
	self.clear_party_member_items()
	# populate items from player inventory
	var member_inventory_items = self.selected_unit_data["unit_weapon_data"]
	for item_id in member_inventory_items:
		var inventory_item_button = inventory_item_button_asset.instance()
		self.party_inventory_item_container.add_child(inventory_item_button)
		inventory_item_button.init(member_inventory_items[item_id], "give")

func _on_party_take_item_button_up(item_button):
	if selected_unit_data != null:
		# get item's type and subtype
		var item_type = item_button.item_data["item_type"]
		var item_subtype = item_button.item_data["item_subtype"]
		# check if the unit can equip the item
		if selected_unit_data["unit_equipable_subtypes"].has(item_subtype):
			print("PartyScreen: equipping, item types: ", item_type, ", ", item_subtype)
			var selected_unit_id = selected_unit_data["unit_id"]
			
			# add item to unit's inventory
			self.root.game_data["unit_data"][selected_unit_id]["unit_weapon_data"][item_button.item_id] = item_button.item_data
			# remove item from player's inventory
			self.root.game_data["main_data"]["player_items"].erase(item_button.item_id)
			
			populate_inventory_items()
			populate_member_inventory_items()
		else:
			print("PartyScreen: Cannot equip, item types: ", item_type, ", ", item_subtype)
			
func _on_party_give_item_button_up(item_button):
	if selected_unit_data != null:
		var selected_unit_id = selected_unit_data["unit_id"]
		var item_data = self.root.game_data["unit_data"][selected_unit_id]["unit_weapon_data"][item_button.item_id]
		# check if item is bound to the character
		var item_is_soulbound : bool = item_data["item_is_soulbound"]
		if !item_is_soulbound:
			# remove item from unit's inventory
			self.root.game_data["unit_data"][selected_unit_id]["unit_weapon_data"].erase(item_button.item_id) 
			# add item to player's inventory
			self.root.game_data["main_data"]["player_items"][item_button.item_id] = item_button.item_data
			populate_inventory_items()
			populate_member_inventory_items()

func _on_award_bonus_xp_button_up():
	# award xp to the currently selected unit
	if selected_unit_data != null:
		var selected_unit_id = selected_unit_data["unit_id"]
		var selected_unit_xp =  selected_unit_data["unit_xp"]
		var selected_unit_xp_max =  selected_unit_data["unit_xp_max"]
		var selected_unit_pending_bonus_xp =  selected_unit_data["unit_pending_bonus_xp"]
		var bonus_xp =  self.root.game_data["main_data"]["bonus_xp"]
		var awarded_xp = min(bonus_xp, selected_unit_xp_max - (selected_unit_xp + selected_unit_pending_bonus_xp))
		self.root.game_data["main_data"]["bonus_xp"] -= awarded_xp
		self.root.game_data["unit_data"][selected_unit_id]["unit_pending_bonus_xp"] += awarded_xp
		
		self.selected_unit_data = self.root.game_data["unit_data"][selected_unit_id]
		self.populate_party_screen()

		

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)