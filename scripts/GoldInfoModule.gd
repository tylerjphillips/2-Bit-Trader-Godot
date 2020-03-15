extends Control

onready var gold_count_label = $GoldCountLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("gold_amount_changed", self, "update_gold_text_label")
	update_gold_text_label()

func update_gold_text_label():
	gold_count_label.text = str(root.game_data["main_data"]["gold"])