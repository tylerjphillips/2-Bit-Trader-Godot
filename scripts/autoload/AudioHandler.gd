extends Node

onready var audio_sample_asset = load("res://scenes/AudioAutomaticPlayer.tscn")

onready var relay = get_node("/root/SignalRelay")

func _ready():
	generate_audio_sample("res://audio/grunt_1.wav")

func generate_audio_sample(audio_path):
	var audio_sample = audio_sample_asset.instance()
	self.add_child(audio_sample)
	audio_sample.init(audio_path)