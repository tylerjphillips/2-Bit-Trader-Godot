extends TextureButton

signal shop_buy_item_button_up
signal shop_sell_item_button_up

var item_id;
var value;
var sell_or_buy : String; # "sell" or "buy"
var item_data

onready var price_label = $ShopItemPriceLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay") 

func _ready():
	self.connect("button_up", self, "_on_ShopItem_button_up")
	# emitters
	self.connect("shop_buy_item_button_up", relay, "_on_shop_buy_item_button_up")
	self.connect("shop_sell_item_button_up", relay, "_on_shop_sell_item_button_up")

func init(item_data, sell_or_buy : String):
	self.item_data = item_data
	self.item_id = item_data["item_id"]
	self.sell_or_buy = sell_or_buy
	assert sell_or_buy in ["sell","buy"]
	if sell_or_buy == "sell":
		self.value = item_data["item_sell_price"]
	else:
		self.value = item_data["item_buy_price"]
	
	# set button attributes
	var item_texture_path = self.item_data["weapon_texture_path"]
	self.texture_normal = load(item_texture_path)
	
	# set the tooltip text to display flavor text and damages
	var tooltip_text = self.item_data.get("weapon_tooltip", "")
	for damage_type in self.item_data["damage"]:
		tooltip_text += "\n" + damage_type + ": " + str(self.item_data["damage"][damage_type])
	self.hint_tooltip = tooltip_text
	
	# set price label
	price_label.text = str(self.value)

func _on_ShopItem_button_up():
	if self.sell_or_buy == "buy":
		emit_signal("shop_buy_item_button_up", self)
	else:
		emit_signal("shop_sell_item_button_up", self)