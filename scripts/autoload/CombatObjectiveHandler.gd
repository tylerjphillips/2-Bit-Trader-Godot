extends Node

signal combat_victory
signal combat_defeat

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# emitters
	self.connect("combat_victory", relay, "_on_combat_victory")
	self.connect("combat_defeat", relay, "_on_combat_defeat")
	# listeners
	relay.connect("round_started", self, "_on_round_started")
	relay.connect("unit_killed", self, "_on_unit_killed")
	
func _on_round_started():
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var current_round = current_event_data["event_current_round"]
	print("CombatObjectiveHander: current round: ", current_round)
	
	# check victory round
	var event_victory_conditions = current_event_data["event_victory_conditions"]
	var event_victory_round = event_victory_conditions["event_victory_round"]
	if event_victory_round <= current_round:
		print("CombatObjectiveHander: YOU ARE WINNER")
		emit_signal("combat_victory")
	
	# check defeat round
	var event_defeat_conditions = current_event_data["event_defeat_conditions"]
	var event_defeat_round = event_defeat_conditions["event_defeat_round"]
	if event_defeat_round <= current_round:
		print("CombatObjectiveHander: YOU HAVE LOST")
		emit_signal("combat_defeat")

func _on_unit_killed(killed_unit, killer_unit):
	# check if a unit was important to the event and decide win or lose
	var killed_unit_id = killed_unit.unit_id
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	
	# victory kills
	var event_victory_kill_unit_ids = self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_kill_unit_ids"]
	if event_victory_kill_unit_ids.has(killed_unit_id):
		# remove the unit from victory conditions
		event_victory_kill_unit_ids.erase(killed_unit_id)
		self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_kill_unit_ids"] = event_victory_kill_unit_ids
		# if less or equal than kill threshold, then victory
		var event_victory_kill_threshold = self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_kill_threshold"]
		if len(event_victory_kill_unit_ids) <= event_victory_kill_threshold:
			print("CombatObjectiveHander: Unit ", killed_unit.unit_name, " killed. YOU ARE WINNER")
			emit_signal("combat_victory")
			
	# defeat kills
	var event_defeat_kill_unit_ids = self.root.game_data["event_data"][current_event_id]["event_defeat_conditions"]["event_defeat_kill_unit_ids"]
	if event_defeat_kill_unit_ids.has(killed_unit_id):
		# remove the unit from defeat conditions
		event_defeat_kill_unit_ids.erase(killed_unit_id)
		self.root.game_data["event_data"][current_event_id]["event_defeat_conditions"]["event_defeat_kill_unit_ids"] = event_defeat_kill_unit_ids
		# if less or equal than kill threshold, then defeat
		var event_defeat_kill_threshold = self.root.game_data["event_data"][current_event_id]["event_defeat_conditions"]["event_defeat_kill_threshold"]
		if len(event_defeat_kill_unit_ids) <= event_defeat_kill_threshold:
			print("CombatObjectiveHander: Unit ", killed_unit.unit_name, " killed. YOU HAVE LOST")
			emit_signal("combat_defeat")