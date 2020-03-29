extends RichTextLabel

class_name RichTextTypewriter

signal typewriter_ended
export var typewriter_speed := .75
var dialogue_typing_has_ended := false

func _ready():
	set_typewriter_bbcode("hi")

func _process(delta):
	if !self.dialogue_typing_has_ended:
		self.percent_visible = min(1, percent_visible + typewriter_speed * delta)
		if self.percent_visible == 1:
			emit_signal("typewriter_ended")
			self.dialogue_typing_has_ended = true
		
func set_typewriter_bbcode(bbcode):
	parse_bbcode(bbcode)
	self.percent_visible = 0
	self.dialogue_typing_has_ended = false