extends Node2D

var event_current_round
onready var round_count_label = $RoundCountLabel

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# listeners
	relay.connect("round_ended", self, "_on_round_ended")
	
	self.init_event_round()
	
func init_event_round():
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	self.event_current_round = current_event_data["event_current_round"]
	self.round_count_label.parse_bbcode("Round: "+str(self.event_current_round))

func add_event_round():
	self.event_current_round += 1
	
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	self.root.game_data["event_data"][current_event_id]["event_current_round"] = self.event_current_round
	
	self.round_count_label.parse_bbcode("Round: "+str(self.event_current_round))

func _on_round_ended():
	self.add_event_round()
