extends RichTextLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

var current_shop_id

func _ready():
	# listeners
	relay.connect("shop_buy_item_succeeded", self, "_on_shop_buy_item_succeeded")
	relay.connect("shop_buy_item_failed", self, "_on_shop_buy_item_failed")
	relay.connect("shop_sell_item_succeeded", self, "_on_shop_sell_item_succeeded")
	
	var current_location_id = root.game_data["main_data"]["current_location_id"]
	self.current_shop_id = self.root.game_data["overworld_data"][current_location_id]["location_shop_id"]
	
	var shop_welcome_bbcode = root.game_data["shop_data"][self.current_shop_id]["shop_welcome_bbcode"]
	self.parse_bbcode(shop_welcome_bbcode)

func _on_shop_buy_item_succeeded():
	var shop_buy_succeeded_bbcode = root.game_data["shop_data"][self.current_shop_id]["shop_buy_succeeded_bbcode"]
	self.parse_bbcode(shop_buy_succeeded_bbcode)

func _on_shop_buy_item_failed():
	var shop_buy_failed_bbcode = root.game_data["shop_data"][self.current_shop_id]["shop_buy_failed_bbcode"]
	self.parse_bbcode(shop_buy_failed_bbcode)
	
func _on_shop_sell_item_succeeded():
	var shop_sell_succeeded_bbcode = root.game_data["shop_data"][self.current_shop_id]["shop_sell_succeeded_bbcode"]
	self.parse_bbcode(shop_sell_succeeded_bbcode)