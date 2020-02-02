extends RichTextLabel
var typewriter_speed := .75
var dialogue_typing_has_ended := false

signal event_dialogue_typing_ended

func _process(delta):
	if !self.dialogue_typing_has_ended:
		self.percent_visible = min(1, percent_visible + typewriter_speed * delta)
		if self.percent_visible == 1:
			emit_signal("event_dialogue_typing_ended")
			self.dialogue_typing_has_ended = true
		
func set_dialogue_text(bbcode):
	parse_bbcode(bbcode)
	self.percent_visible = 0
	self.dialogue_typing_has_ended = false