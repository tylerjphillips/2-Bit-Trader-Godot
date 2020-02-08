extends Button

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# emitters
	self.connect("button_up", relay, "_on_end_turn_button_pressed")