extends Node2D

var round_count = 1
onready var round_count_label = $RoundCountLabel

onready var relay = get_node("/root/SignalRelay")

func _ready():
	relay.connect("round_ended", self, "_on_round_ended")
	self.round_count_label.parse_bbcode("Round: "+str(self.round_count))
	
func _on_round_ended():
	self.round_count += 1
	self.round_count_label.parse_bbcode("Round: "+str(self.round_count))
