extends AudioStreamPlayer

onready var relay = get_node("/root/SignalRelay")
var audio_path

signal audio_finished

func _ready():
	# emitters
	self.connect("finished", self, "_on_finished")
	self.connect("audio_finished", relay, "_on_audio_finished")
	# listeners

func init(audio_path):
	print("AudioAutomaticPlayer: ", audio_path)
	self.audio_path = audio_path
	self.stream = load(audio_path)
	self.play()

func _on_finished():
	emit_signal("audio_finished", self.audio_path)
	self.queue_free()