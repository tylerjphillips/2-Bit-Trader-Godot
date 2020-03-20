extends Button

# undo variables
var unit_undo_order = Array() # stack of units representing movement order.
var unit_undo_state = Array() # stack of unit states to revert unit to previous state on undo

signal undo_button_pressed # (undo_unit, undo_unit_state)

onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "undo_button_pressed")
	# emitters
	
	self.connect("undo_button_pressed", relay, "_on_undo_button_pressed")
	
	# listeners
	relay.connect("unit_attacks_tile", self, "_on_unit_attacks_tile")
	relay.connect("unit_killed", self, "_on_unit_killed")
	relay.connect("unit_moved", self, "_on_unit_moved")
	relay.connect("team_end_turn", self, "_on_team_end_turn")

func clear_undo_stack():
	self.unit_undo_order.clear()
	self.unit_undo_state.clear()

func _on_unit_moved(unit, previous_tile_index, tile_index, movement_cost):
	# push the last unit and its state onto a stack. Modify the saved state to include the previous tile index it moved from
	self.unit_undo_order.push_back(unit)
	var unit_repr = unit.get_unit_repr()
	unit_repr["unit_tile_index"] = previous_tile_index
	self.unit_undo_state.push_back(unit_repr)

func _on_team_end_turn(team):
	self.clear_undo_stack()

func _on_unit_killed(killed_unit, killer_unit):
	# clear the stack when a unit dies
	self.clear_undo_stack()

func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	# clear the stack when a unit attacks something
	self.clear_undo_stack()
	
func undo_button_pressed():
	if len(self.unit_undo_order) > 0:
		# pop the last unit to move and pass it and its previous state out to be handled
		var undo_unit = self.unit_undo_order.pop_back()
		var undo_unit_state = self.unit_undo_state.pop_back()
		emit_signal("undo_button_pressed", undo_unit, undo_unit_state)
