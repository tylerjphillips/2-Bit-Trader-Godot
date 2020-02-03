extends GridContainer

onready var item_button_asset = preload("res://scenes/combat/ItemButton.tscn")

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("unit_selected", self, "_on_unit_selected")

func _on_unit_selected(unit):
	for itembutton in self.get_children():
		itembutton.queue_free()
	print("ItemButtonGridContainer: populating items")
	for weapon_id in unit.unit_weapon_data:
		var item_button = item_button_asset.instance()
		self.add_child(item_button)
		item_button.init(unit, weapon_id)