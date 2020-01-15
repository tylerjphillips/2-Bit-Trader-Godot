extends Node

# tilemap related
signal batch_spawn_units
signal set_tiles

signal change_scene
signal update_game_data

onready var root = get_tree().get_root().get_node("Root")
onready var change_scene_button = get_node("ChangeSceneButton")	

func _ready():
	assert root
	assert change_scene_button
	change_scene_button.connect("change_scene", self, "change_scene")
	

func init(game_data):
	var event_data = game_data["event_data"]
	print("EventScreen: ", event_data)
	
func change_scene(new_scene_name):
	update_all_unit_data()
	emit_signal("change_scene", "combat_screen", new_scene_name)
	
####### Serialization ########

func update_all_unit_data():
	for unit in get_tree().get_nodes_in_group("units"):
		unit.update_global_data_entry()