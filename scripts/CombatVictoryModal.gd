extends Node2D

onready var relay = get_node("/root/SignalRelay")

func _ready():
	relay.connect("combat_victory", self, "open_victory_modal")

func open_victory_modal():
	self.show()