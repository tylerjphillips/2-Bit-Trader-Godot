extends Button

signal overworld_rest_button_up

onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "_on_RestPartyButton_button_up")
	# emitters
	self.connect("overworld_rest_button_up", relay, "_on_overworld_rest_button_up")

func _on_RestPartyButton_button_up():
	emit_signal("overworld_rest_button_up")
