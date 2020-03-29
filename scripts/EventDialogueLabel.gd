extends RichTextTypewriter

signal event_dialogue_typing_ended

func _ready():
	self.connect("typewriter_ended", self, "_on_typewriter_ended")

func _on_typewriter_ended():
	emit_signal("event_dialogue_typing_ended")