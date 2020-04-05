extends Node

onready var audio_sample_asset = load("res://scenes/AudioAutomaticPlayer.tscn")

var current_music_sample

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

const screens_to_music = {
	"shop_screen": "shop_music", 
	"combat_screen": "combat_music",
	"overworld_screen": "overworld_music",
	"event_screen": "overworld_music"
} 

func _ready():
	# listeners
	relay.connect("audio_finished", self, "_on_audio_finished")
	relay.connect("unit_attacks_unit", self, "_on_unit_attacks_unit")
	relay.connect("unit_attacks_tile", self, "_on_unit_attacks_tile")
	relay.connect("unit_killed", self, "_on_unit_killed")
	relay.connect("unit_leveled_up", self, "_on_unit_leveled_up")
	relay.connect("change_scene", self, "_on_change_scene")
	
	relay.connect("shop_buy_item_button_up",self, "_on_shop_buy_item_button_up")
	relay.connect("shop_sell_item_button_up",self, "_on_shop_sell_item_button_up")
	relay.connect("shop_confirm_button_up",self, "_on_shop_confirm_button_up")
	
	relay.connect("shop_buy_item_succeeded", self, "_on_shop_buy_item_succeeded")
	relay.connect("shop_sell_item_succeeded", self, "_on_shop_sell_item_succeeded")

func _on_shop_buy_item_button_up(item_button):
	self.generate_audio_sample(self.root.game_data["audio_data"]["button_click"])
func _on_shop_sell_item_button_up(item_button):
	self.generate_audio_sample(self.root.game_data["audio_data"]["button_click"])
func _on_shop_confirm_button_up(item_button):
	self.generate_audio_sample(self.root.game_data["audio_data"]["button_click"])
	
func _on_shop_buy_item_succeeded():
	self.generate_audio_sample(self.root.game_data["audio_data"]["transaction_coins"])
func _on_shop_sell_item_succeeded():
	self.generate_audio_sample(self.root.game_data["audio_data"]["transaction_coins"])

func _on_change_scene(old_scene_name, new_scene_name):
	var old_music = screens_to_music.get(old_scene_name, "")
	var new_music = screens_to_music.get(new_scene_name, "")
	
	# turn off the music on scene change
	if current_music_sample != null and new_music != old_music:
		self.current_music_sample.fade_out_volume()
		self.current_music_sample = null
	if new_music != "" and new_music != old_music:
		self.current_music_sample = self.generate_audio_sample(self.root.game_data["audio_data"][new_music], true)

func _on_audio_finished(audio_path):
	pass

func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	self.generate_audio_sample(attacking_unit_weapon_data["weapon_attack_audio_path"])

func _on_unit_attacks_unit(attacking_unit, damage_pattern, attacked_unit, damage_tile_index):
	self.generate_audio_sample(attacked_unit.unit_damaged_audio_path)

func _on_unit_killed(killed_unit, killer_unit):
	self.generate_audio_sample(killed_unit.unit_death_audio_path)
	
func _on_unit_leveled_up(unit):
	generate_audio_sample(self.root.game_data["audio_data"]["unit_level_up_sound"])
	


func generate_audio_sample(audio_path, fade_in = false):
	var audio_sample = audio_sample_asset.instance()
	self.add_child(audio_sample)
	audio_sample.init(audio_path, fade_in)
	return audio_sample