extends Button

signal award_bonus_xp_button_up

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "_on_AwardBonusXPButton_up")
	# emitters
	self.connect("award_bonus_xp_button_up", relay, "_on_award_bonus_xp_button_up")
	
	
func _on_AwardBonusXPButton_up():
	emit_signal("award_bonus_xp_button_up")