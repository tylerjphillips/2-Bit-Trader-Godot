extends Node

signal change_scene
signal update_game_data

func _ready():
	pass

func init(game_data):
	print("hai")

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)
