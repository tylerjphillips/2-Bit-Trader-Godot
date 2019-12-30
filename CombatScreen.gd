extends Node

# tilemap related
signal batch_spawn_units
signal set_tiles

signal change_scene

func init(game_data):
	var unit_data = game_data["unit_data"]
	var tile_data = game_data["tile_data"]
	emit_signal("batch_spawn_units", unit_data)
	emit_signal("set_tiles", tile_data)