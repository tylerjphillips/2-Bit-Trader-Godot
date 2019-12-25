extends Node

const units_json_path = "res://configs/units.json"

signal batch_spawn_units # (unit_data)

func _ready():
	print("CombatScreen: Loading Room")
	var data_file = File.new()
	if data_file.open(units_json_path, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
	    return
	var unit_data = data_parse.result
	
	emit_signal("batch_spawn_units", unit_data)