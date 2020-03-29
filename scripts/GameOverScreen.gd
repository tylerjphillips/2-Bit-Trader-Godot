extends Node2D

signal change_scene # (old_scene_name, new_scene_name)

onready var change_scene_button = $ChangeSceneButton

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# emitters
	self.connect("change_scene", relay, "_on_change_scene")
	# button signals
	change_scene_button.connect("change_scene", self, "change_scene")

func init(game_data):
	pass

func change_scene(new_scene_name):
	emit_signal("change_scene", "game_over_screen", new_scene_name)