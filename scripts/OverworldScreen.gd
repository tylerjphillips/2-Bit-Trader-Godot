extends Node

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")

func _ready():
	pass

func init(game_data):
	pass

func change_scene(new_scene_name):
	emit_signal("change_scene", "overworld_screen", new_scene_name)