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
	relay.connect("unit_moved", self, "_on_unit_moved")
	
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
			
func _on_unit_moved(unit, previous_tile_index, tile_index, movement_cost):
	# check if certain units have moved into a defined region to create a victory or loss condition
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	
	# victory movement
	var event_victory_conditions = self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]
	if event_victory_conditions.has("event_victory_units_move_to_region"):
		var event_victory_units_move_to_region = self.root.game_data["event_data"][current_event_id]["event_victory_conditions"]["event_victory_units_move_to_region"]
		var unit_ids = event_victory_units_move_to_region["unit_ids"]
		var region_tile_indexes = event_victory_units_move_to_region["region_tile_indexes"]
		if unit.unit_id in unit_ids:
			if [tile_index[0], tile_index[1]] in region_tile_indexes:
				print("CombatObjectiveHander: Unit ", unit.unit_name, " moved to region.",region_tile_indexes ," YOU HAVE WON")
				emit_signal("combat_victory")
				
	# defeat movement
	var event_defeat_conditions = self.root.game_data["event_data"][current_event_id]["event_defeat_conditions"]
	if event_defeat_conditions.has("event_defeat_units_move_to_region"):
		var event_defeat_units_move_to_region = self.root.game_data["event_data"][current_event_id]["event_defeat_conditions"]["event_defeat_units_move_to_region"]
		var unit_ids = event_defeat_units_move_to_region["unit_ids"]
		var region_tile_indexes = event_defeat_units_move_to_region["region_tile_indexes"]
		if unit.unit_id in unit_ids:
			if [tile_index[0], tile_index[1]] in region_tile_indexes:
				print("CombatObjectiveHander: Unit ", unit.unit_name, " moved to region.",region_tile_indexes ," YOU HAVE LOST")
				emit_signal("combat_defeat")
	
	