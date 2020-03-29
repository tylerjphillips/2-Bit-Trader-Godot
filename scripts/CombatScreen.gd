extends Node

signal change_scene # (old_scene_name, new_scene_name)

onready var tilemap = get_node("TileMap")
onready var root = get_tree().get_root().get_node("Root")
onready var change_scene_button = get_node("ChangeSceneButton")	
onready var end_turn_button = get_node("EndTurnButton")
onready var selected_unit_info = get_node("SelectedUnitInfo") # unit info UI module
onready var unit_selection_sidebar = get_node("UnitSelectionSidebar") #	Sidebar for seeing all units on player team

onready var relay = get_node("/root/SignalRelay")

func _ready():
	assert tilemap
	assert root
	assert change_scene_button
	assert end_turn_button
	assert selected_unit_info
	assert unit_selection_sidebar
	# emitters
	self.connect("change_scene", relay, "_on_change_scene")
	
	# button signals
	change_scene_button.connect("change_scene", self, "change_scene")
	$CombatVictoryModal/UIBackground/ChangeSceneButton.connect("change_scene", self, "change_scene")

func init(game_data):
	var unit_data = game_data["unit_data"]
	tilemap.init()
	
func change_scene(new_scene_name):
	update_all_unit_data()
	emit_signal("change_scene", "combat_screen", new_scene_name)
	
####### Serialization ########

func update_all_unit_data():
	for unit in get_tree().get_nodes_in_group("units"):
		unit.update_global_data_entry()