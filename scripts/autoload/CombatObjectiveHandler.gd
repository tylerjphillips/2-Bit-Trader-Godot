extends Node

signal combat_victory
signal combat_loss

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# emitters
	self.connect("combat_victory", relay, "_on_combat_victory")
	self.connect("combat_loss", relay, "_on_combat_loss")
	# listeners
	relay.connect("round_started", self, "_on_round_started")
	
func _on_round_started():
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var current_round = current_event_data["event_current_round"]
	print("CombatObjectiveHander: current round: ", current_round)
	var event_victory_conditions = current_event_data["event_victory_conditions"]
	var event_victory_round = event_victory_conditions["event_victory_round"]
	if event_victory_round <= current_round:
		print("CombatObjectiveHander: YOU ARE WINNER")
		emit_signal("combat_victory")
