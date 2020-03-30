extends Control

onready var day_count_label = $DayCountLabel
onready var max_day_count_label = $MaxDayCountLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("day_ended", self, "_on_day_ended")
	update_day_text_label()

func update_day_text_label():
	day_count_label.text = str(self.root.game_data["main_data"]["day"])
	var days_until_defeat = self.root.game_data["main_data"]["days_until_defeat"]
	if days_until_defeat != -1:
		day_count_label.text += " / " + str(days_until_defeat)

func _on_day_ended():
	self.update_day_text_label()