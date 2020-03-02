extends Control

onready var day_count_label = $DayCountLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("day_ended", self, "update_day_text_label")
	update_day_text_label()


func update_day_text_label():
	day_count_label.text = str(self.root.game_data["main_data"]["day"])