extends Node

signal change_scene # (old_scene_name, new_scene_name)

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("change_scene", relay, "_on_change_scene")

func init(game_data):
	pass
	
func change_scene(new_scene_name):
	emit_signal("change_scene", "title_screen", new_scene_name)