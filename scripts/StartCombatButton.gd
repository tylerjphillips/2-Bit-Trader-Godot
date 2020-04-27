extends Button

signal combat_party_selection_finish_button_pressed

onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "_on_CombatPartySelectionUnit_toggled")
	# emitters
	self.connect("combat_party_selection_finish_button_pressed", relay, "_on_combat_party_selection_finish_button_pressed")

func _on_CombatPartySelectionUnit_toggled():
	emit_signal("combat_party_selection_finish_button_pressed")
