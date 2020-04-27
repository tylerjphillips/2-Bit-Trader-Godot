extends Button

signal combat_selecton_button_toggled # (button)

var unit_data	# must be assigned to a unit. Corresponds to the

onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("toggled", self, "_on_CombatPartySelectionUnit_toggled")
	# emitters
	self.connect("combat_selecton_button_toggled", relay, "_on_combat_selecton_button_toggled")

func init(unit_data):
	self.unit_data = unit_data
	self.text = unit_data["unit_name"]
	self.icon = load(unit_data["unit_texture_path"])

func _on_CombatPartySelectionUnit_toggled(press_state):
	emit_signal("combat_selecton_button_toggled", self)
