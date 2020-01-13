extends Node

# tilemap related
signal batch_spawn_units
signal set_tiles

signal change_scene
signal update_game_data

onready var tilemap = get_node("TileMap")
onready var root = get_tree().get_root().get_node("Root")

func init(game_data):
	var unit_data = game_data["unit_data"]
	var current_map_id = game_data["main_data"]["current_map_id"]
	var tile_data = game_data["map_data"][current_map_id]
	emit_signal("batch_spawn_units", unit_data)
	emit_signal("set_tiles", tile_data)
	
func change_scene(new_scene_name):
	update_all_unit_data()
	emit_signal("change_scene", "combat_screen", new_scene_name)
	
####### Serialization ########

func update_all_unit_data():
	for unit in get_tree().get_nodes_in_group("units"):
		unit.update_global_data_entry()