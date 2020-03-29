extends Button

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# emitters
	self.connect("button_up", relay, "_on_end_turn_button_pressed")
	# listeners
	relay.connect("combat_defeat", self, "_on_combat_defeat")
	relay.connect("combat_victory", self, "_on_combat_victory")
	
func _on_combat_defeat():
	self.disabled = true
func _on_combat_victory():
	self.disabled = true	