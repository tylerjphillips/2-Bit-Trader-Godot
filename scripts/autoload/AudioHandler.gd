extends Node

onready var audio_sample_asset = load("res://scenes/AudioAutomaticPlayer.tscn")

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# listeners
	relay.connect("unit_attacks_unit", self, "_on_unit_attacks_unit")
	relay.connect("unit_attacks_tile", self, "_on_unit_attacks_tile")
	relay.connect("unit_killed", self, "_on_unit_killed")

func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	self.generate_audio_sample(attacking_unit_weapon_data["weapon_attack_audio_path"])

func _on_unit_attacks_unit(attacking_unit, weapon_data, attacked_unit, damage_tile_index):
	self.generate_audio_sample(attacked_unit.unit_damaged_audio_path)

func _on_unit_killed(killed_unit, killer_unit):
	self.generate_audio_sample(killed_unit.unit_death_audio_path)

func generate_audio_sample(audio_path):
	var audio_sample = audio_sample_asset.instance()
	self.add_child(audio_sample)
	audio_sample.init(audio_path)