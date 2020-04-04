extends AudioStreamPlayer

onready var relay = get_node("/root/SignalRelay")
var audio_path

signal audio_finished

onready var volume_out_tween = $VolumeFadeOutTween
onready var volume_in_tween = $VolumeFadeInTween

export var fade_out_db = -80
export var fade_out_time = 3
export var fade_in_db = -20
export var fade_in_time = 2

func _ready():
	# emitters
	self.connect("finished", self, "_on_finished")
	self.connect("audio_finished", relay, "_on_audio_finished")
	# listeners
	volume_out_tween.connect("tween_completed", self, "_on_fade_out")

func init(audio_path, fade_in = false):
	print("AudioAutomaticPlayer: ", audio_path)
	self.audio_path = audio_path
	self.stream = load(audio_path)
	self.play()
	if fade_in:
		self.fade_in_volume()

func fade_in_volume():
	volume_in_tween.interpolate_property(self, "volume_db", self.fade_out_db, self.fade_in_db, self.fade_in_time ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	volume_in_tween.start()

func fade_out_volume():
	volume_out_tween.interpolate_property(self, "volume_db", self.fade_in_db, self.fade_out_db, self.fade_out_time ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	volume_out_tween.start()

func _on_fade_out():
	self._on_finished()

func _on_finished():
	emit_signal("audio_finished", self.audio_path)
	self.queue_free()
	
