extends Node2D

# contains all data needed to run the game. Serves as a way to store/transfer data between scenes 
var game_data = Dictionary()

# scenes
var title_screen = preload("res://scenes/title/TitleScreen.tscn")
var combat_screen = preload("res://scenes/combat/CombatScreen.tscn")
var shop_screen = preload("res://scenes/shop/ShopScreen.tscn")
var party_screen = preload("res://scenes/party/PartyScreen.tscn")
var overworld_screen = preload("res://scenes/overworld/OverworldScreen.tscn")
var event_screen = preload("res://scenes/event/EventScreen.tscn")
var recruitment_screen = preload("res://scenes/recruitment/RecruitmentScreen.tscn")
var game_over_screen = preload("res://scenes/game_over/GameOverScreen.tscn")
var new_campaign_screen = preload("res://scenes/new_campaign/CampaignListScreen.tscn")

# colors used for team indication
const colors = {
	"white":Color(1, 1, 1, 0.8),
	"red":Color(0.8, 0.0, 0.0, 0.8),
	"green":Color(0.0, 0.8, 0.2, 0.8),
	"blue":Color(0.2, 0.2, 0.8, 0.8),
	}

# map scene names to prefabs
var scene_names_to_scene = {
	"title_screen": self.title_screen,
	"combat_screen" : self.combat_screen,
	"shop_screen" : self.shop_screen,
	"party_screen" : self.party_screen,
	"overworld_screen" : self.overworld_screen,
	"event_screen": self.event_screen,
	"recruitment_screen": self.recruitment_screen,
	"game_over_screen": self.game_over_screen,
	"new_campaign_screen": self.new_campaign_screen
	}

var current_scene	 # reference to instance of currently active scene

# config paths
	# directory holding the game data files
var config_directory = "res://configs/"
var meta_json_filename = "meta.json"	 # holds all paths to other data files


onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("load_campaign_button_pressed", self, "_on_load_campaign_button_pressed")
	
	# initialize game
	print("Root: Game Start")
	self.batch_load_json(config_directory)
	self.create_scene("title_screen")

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
	self.game_data["meta_data"] = self.load_json(directory,meta_json_filename)
	for data_key in self.game_data["meta_data"]:
		self.game_data[data_key] = self.load_json(directory,self.game_data["meta_data"][data_key])

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
	
func _on_load_campaign_button_pressed(campaign_data):
	print("Root: load campaign button pressed")
	self.game_data.clear()
	self.meta_json_filename = campaign_data["campaign_meta_path"]
	self.config_directory = campaign_data["campaign_directory_path"]
	self.batch_load_json(config_directory)
	_on_change_scene("", "event_screen")
	