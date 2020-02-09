extends Node

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")

func _ready():
	pass
	# change_scene_button.connect("change_scene", self, "change_scene")
	# event_dialogue.connect("event_dialogue_typing_ended", self, "_on_event_dialogue_typing_ended")

func init(game_data):
	pass
	
func change_scene(new_scene_name):
	emit_signal("change_scene", "title_screen", new_scene_name)