extends TextureRect

signal event_choice_selected	# choice_id

var choice_data
onready var event_choice_label = $EventChoiceLabel
onready var event_choice_button = $EventChoiceButton

func init(choice_data):
	self.choice_data = choice_data
	event_choice_label.parse_bbcode(choice_data["choice_bbcode"])
	
	event_choice_button.connect("button_up", self, "_on_EventChoiceButton_button_up")

func _on_EventChoiceButton_button_up():
	emit_signal("event_choice_selected", self.choice_data)
