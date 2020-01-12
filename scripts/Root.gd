extends Node2D

# contains all data needed to run the game. Serves as a way to store/transfer data between scenes 
var game_data = Dictionary()

# scenes
var combat_screen = preload("res://scenes/CombatScreen.tscn")
var shop_screen = preload("res://scenes/ShopScreen.tscn")
var party_screen = preload("res://scenes/PartyScreen.tscn")

# colors used for team indication
const colors = {
	"white":Color(1, 1, 1, 0.8),
	"red":Color(0.8, 0.0, 0.0, 0.8),
	"green":Color(0.0, 0.8, 0.2, 0.8),
	"blue":Color(0.2, 0.2, 0.8, 0.8),
	}

# map scene names to prefabs
var scene_names_to_scene = {
	"combat_screen" : self.combat_screen,
	"shop_screen" : self.shop_screen,
	"party_screen" : self.party_screen
	}

var current_scene	 # reference to instance of currently active scene

# config paths
	# directory holding the game data files
const config_directory = "res://configs/"
	# json filenames in selected config_directory
const units_json_filename = "units.json"
const tiles_json_filename = "tiles.json"
const main_json_filename = "main.json"

func _ready():
	print("Root: Game Start")
	self.batch_load_json(config_directory)
	self.create_scene("combat_screen")

func load_json(directory, filename):
	print("Root: loading ", filename)
	
	# returns dict from json filename
	var data_file = File.new()
	if data_file.open(directory+filename, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("error parsing json "+filename)
		return
	return data_parse.result
	
func save_json(directory, filename, data):
	print("Root: saving ", filename)
	var file = File.new()
	if file.open(directory+filename, File.WRITE) != 0:
	    print("Error opening file")
	    return
	
	file.store_line(to_json(data))
	file.close()




func batch_load_json(directory):
	# loads data from a directory
	print("Root loading configs from ", directory, " .....")
	self.game_data["unit_data"] = self.load_json(directory,units_json_filename)
	self.game_data["tile_data"] = self.load_json(directory,tiles_json_filename)
	self.game_data["main_data"] = self.load_json(directory,main_json_filename)

func create_scene(scene_name):
	self.current_scene = self.scene_names_to_scene[scene_name].instance()
	self.add_child(current_scene)
	self.current_scene.connect("change_scene", self, "_on_change_scene")
	self.current_scene.connect("update_game_data", self, "_on_update_game_data")
	self.current_scene.init(self.game_data)
	
func _on_change_scene(old_scene_name, new_scene_name):
	self.current_scene.queue_free()
	self.create_scene(new_scene_name)
	
func _on_update_game_data(key, data):
	print("Root: updating game data") 
	self.game_data[key] = data
	
