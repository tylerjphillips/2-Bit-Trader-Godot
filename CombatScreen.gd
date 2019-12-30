extends Node

signal batch_spawn_units
signal change_scene

func init(game_data):
	var unit_data = game_data["unit_data"]
	emit_signal("batch_spawn_units", unit_data)