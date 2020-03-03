extends Control

signal party_take_item_button_up
signal party_give_item_button_up

var item_id;
var value;
var give_or_take : String; # "give" or "take"
var item_data

onready var inventory_item_button = $InventoryItemButton
onready var item_soulbound_indicator = $ItemSoulBoundIndicator

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay") 

func _ready():
	assert inventory_item_button
	assert item_soulbound_indicator
	
	inventory_item_button.connect("button_up", self, "_on_InventoryItem_button_up")
	# emitters
	self.connect("party_take_item_button_up", relay, "_on_party_take_item_button_up")
	self.connect("party_give_item_button_up", relay, "_on_party_give_item_button_up")

func init(item_data, give_or_take : String):
	self.item_data = item_data
	self.item_id = item_data["item_id"]
	self.give_or_take = give_or_take
	assert give_or_take in ["give","take"]
	
	# set button attributes
	var item_texture_path = self.item_data["weapon_texture_path"]
	inventory_item_button.texture_normal = load(item_texture_path)
	
	# soulbound indication
	item_soulbound_indicator.hide()
	if item_data["item_is_soulbound"]:
		item_soulbound_indicator.show()

func _on_InventoryItem_button_up():
	if self.give_or_take == "give":
		emit_signal("party_give_item_button_up", self)
	else:
		emit_signal("party_take_item_button_up", self)