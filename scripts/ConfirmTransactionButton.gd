extends Button

signal shop_confirm_button_up # (item_button)

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

var item_button	# last pressed item button

func _ready():
	self.connect("button_up", self, "_on_ConfirmTransaction_button_up")
	
	# emitters
	self.connect("shop_confirm_button_up", relay, "_on_shop_confirm_button_up")
	# listeners
	relay.connect("shop_buy_item_button_up", self, "_on_shop_buy_item_button_up")
	relay.connect("shop_sell_item_button_up", self, "_on_shop_sell_item_button_up")
	
func _on_ConfirmTransaction_button_up():
	self.hide()
	emit_signal("shop_confirm_button_up", self.item_button)
	
func _on_shop_buy_item_button_up(item_button):
	self.show()
	self.item_button = item_button
	
func _on_shop_sell_item_button_up(item_button):
	self.show()
	self.item_button = item_button