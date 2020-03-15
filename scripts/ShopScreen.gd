extends Node

onready var overworld_screen_button = $ChangeSceneButtonOverworldScreen

signal change_scene

signal shop_buy_item_failed
signal shop_buy_item_succeeded
signal shop_sell_item_succeeded

signal gold_amount_changed # (gold)

var shop_item_button_asset = preload("res://scenes/shop/ShopItemButton.tscn")

onready var buy_item_container = $BuyItemContainer/BuyItemGridContainer
onready var sell_item_container = $SellItemContainer/SellItemGridContainer

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	overworld_screen_button.connect("change_scene", self, "change_scene")
	
	# emitters
	self.connect("shop_buy_item_failed", relay, "_on_shop_buy_item_failed")
	self.connect("shop_buy_item_succeeded", relay, "_on_shop_buy_item_succeeded")
	self.connect("shop_sell_item_succeeded", relay, "_on_shop_sell_item_succeeded")
	self.connect("gold_amount_changed", relay, "_on_gold_amount_changed")
	
	# listeners
	relay.connect("shop_buy_item_button_up", self, "attempt_buy_item")
	relay.connect("shop_sell_item_button_up", self, "sell_item")

func init(game_data):
	# add items to buy and sell
	populate_shop_items()

func get_shop_items():
	# helper method for getting items from the current location's shop
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	var current_shop_id = self.root.game_data["overworld_data"][current_location_id]["location_shop_id"]
	var shop_items = self.root.game_data["shop_data"][current_shop_id]["shop_items"]
	return shop_items
	
func clear_shop_items():
	for item_button in self.buy_item_container.get_children():
		item_button.queue_free()
	for item_button in self.sell_item_container.get_children():
		item_button.queue_free()
	
func populate_shop_items():
	clear_shop_items()
	
	# populate sell items from player inventory
	var player_party_items = self.root.game_data["main_data"]["player_items"]
	for item_id in player_party_items:
		var sell_item_button = shop_item_button_asset.instance()
		self.sell_item_container.add_child(sell_item_button)
		sell_item_button.init(player_party_items[item_id], "sell")
	
	# populate buy items from shop inventory
	var shop_items = self.get_shop_items()
	for item_id in shop_items:
		var buy_item_button = shop_item_button_asset.instance()
		self.buy_item_container.add_child(buy_item_button)
		buy_item_button.init(shop_items[item_id], "buy")
		
func attempt_buy_item(item_button):
	var player_gold = self.root.game_data["main_data"]["gold"]
	if player_gold >= item_button.value:
		self.buy_item(item_button)
	else:
		emit_signal("shop_buy_item_failed")

func buy_item(item_button):
	# remove value from player
	self.root.game_data["main_data"]["gold"] = self.root.game_data["main_data"]["gold"] - item_button.value
	emit_signal("gold_amount_changed")
	
	print("ShopScreen: Bought. Remaining gold: ", self.root.game_data["main_data"]["gold"])
	
	# remove from shop
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	var current_shop_id = self.root.game_data["overworld_data"][current_location_id]["location_shop_id"]
	self.root.game_data["shop_data"][current_shop_id]["shop_items"].erase(item_button.item_id)
	
	# add to player inventory
	self.root.game_data["main_data"]["player_items"][item_button.item_id] = item_button.item_data
	
	# rerender items
	self.populate_shop_items()
	
	emit_signal("shop_buy_item_succeeded")

func sell_item(item_button):
	# add value to player
	self.root.game_data["main_data"]["gold"] = self.root.game_data["main_data"]["gold"] + item_button.value
	emit_signal("gold_amount_changed")
	
	print("ShopScreen: Sold. Remaining gold: ", self.root.game_data["main_data"]["gold"])
	
	# add to shop
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	var current_shop_id = self.root.game_data["overworld_data"][current_location_id]["location_shop_id"]
	self.root.game_data["shop_data"][current_shop_id]["shop_items"][item_button.item_id] = item_button.item_data
	
	# remove from player inventory
	self.root.game_data["main_data"]["player_items"].erase(item_button.item_id)
	
	# rerender items
	self.populate_shop_items()
	
	emit_signal("shop_sell_item_succeeded")
	

func change_scene(new_scene_name):
	emit_signal("change_scene", "shop_screen", new_scene_name)