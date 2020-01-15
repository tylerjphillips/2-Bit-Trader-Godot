extends Node

# tilemap related
signal batch_spawn_units
signal set_tiles

signal change_scene
signal update_game_data

onready var tilemap = get_node("TileMap")
onready var root = get_tree().get_root().get_node("Root")
onready var change_scene_button = get_node("ChangeSceneButton")	
onready var end_turn_button = get_node("EndTurnButton")
onready var selected_unit_info = get_node("SelectedUnitInfo") # unit info UI module
onready var unit_selection_sidebar = get_node("UnitSelectionSidebar") #	Sidebar for seeing all units on player team
onready var movement_attack_overlay = get_node("MovementAttackOverlay") # movement and attack indicator

func _ready():
	assert tilemap
	assert root
	assert change_scene_button
	assert end_turn_button
	assert selected_unit_info
	assert unit_selection_sidebar
	assert movement_attack_overlay
	
	# movement and attack overlay signals
	tilemap.connect("clear_attack_tiles", movement_attack_overlay, "_on_clear_attack_tiles")
	tilemap.connect("clear_movement_tiles", movement_attack_overlay, "_on_clear_movement_tiles")
	tilemap.connect("create_attack_tiles", movement_attack_overlay, "_on_create_attack_tiles")
	tilemap.connect("create_movement_tiles", movement_attack_overlay, "_on_create_movement_tiles")
	# selection info signals
	tilemap.connect("unit_selected", selected_unit_info, "_on_unit_selected")
	tilemap.connect("unit_deselected", selected_unit_info, "_on_unit_deselected")

	self.connect("batch_spawn_units", tilemap, "_on_batch_spawn_units")
	self.connect("set_tiles", tilemap, "_on_set_tiles")
	
	# button signals
	end_turn_button.connect("button_up", tilemap, "_on_EndTurnButton_button_up")
	change_scene_button.connect("change_scene", self, "change_scene")
	

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