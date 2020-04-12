extends Button

signal award_bonus_xp_button_up

onready var remaining_bonus_xp_label = $RemainingBonusXPLabel

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("button_up", self, "_on_AwardBonusXPButton_up")
	# emitters
	self.connect("award_bonus_xp_button_up", relay, "_on_award_bonus_xp_button_up")
	remaining_bonus_xp_label.text = str(self.root.game_data["main_data"]["bonus_xp"]) + " Remaining"
	
	
func _on_AwardBonusXPButton_up():
	emit_signal("award_bonus_xp_button_up")
	remaining_bonus_xp_label.text = str(self.root.game_data["main_data"]["bonus_xp"]) + " Remaining"