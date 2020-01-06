extends Node

# tilemap related
signal batch_spawn_units
signal set_tiles

signal change_scene
signal update_game_data

onready var tilemap = get_node("TileMap")

func init(game_data):
	var unit_data = game_data["unit_data"]
	var tile_data = game_data["tile_data"]
	emit_signal("batch_spawn_units", unit_data)
	emit_signal("set_tiles", tile_data)
	
func change_scene(new_scene_name):
	emit_signal("update_game_data", "unit_data", self.tilemap.get_all_unit_data())
	emit_signal("change_scene", "combat_screen", new_scene_name)