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
	relay.connect("unit_killed", self, "_on_unit_killed")
	
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

func _on_unit_killed(killed_unit):
	# check if a unit was important to the event and decide win or lose
	var killed_unit_id = killed_unit.unit_id
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var event_victory_kill_unit_ids = self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_kill_unit_ids"]
	if event_victory_kill_unit_ids.has(killed_unit_id):
		# remove the unit from victory conditions
		event_victory_kill_unit_ids.erase(killed_unit_id)
		self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_kill_unit_ids"] = event_victory_kill_unit_ids
		# if that was the last important unit, then victory
		if len(event_victory_kill_unit_ids) == 0:
			print("CombatObjectiveHander: Unit ", killed_unit.unit_name, " killed. YOU ARE WINNER")
			emit_signal("combat_victory")