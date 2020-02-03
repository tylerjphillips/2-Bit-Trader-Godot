extends Node

onready var overworld_screen_button = $ChangeSceneButtonOverworldScreen

signal change_scene

func _ready():
	overworld_screen_button.connect("change_scene", self, "change_scene")

func init(game_data):
	pass
	
func change_scene(new_scene_name):
	emit_signal("change_scene", "shop_screen", new_scene_name)