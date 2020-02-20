extends Node2D

signal change_scene

onready var change_scene_button = $ChangeSceneButton

func _ready():
	# button signals
	change_scene_button.connect("change_scene", self, "change_scene")

func init(game_data):
	pass

func change_scene(new_scene_name):
	emit_signal("change_scene", "combat_victory_screen", new_scene_name)