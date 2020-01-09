extends Node

signal change_scene
signal update_game_data

onready var party_grid = get_node("ScrollContainer/PartyGrid")

func _ready():
	pass

func init(game_data):
	pass

func change_scene(new_scene_name):
	emit_signal("change_scene", "party_screen", new_scene_name)