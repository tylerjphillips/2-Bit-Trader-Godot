extends Node2D

signal combat_party_selection_finished(selected_party_unit_ids)

var combat_selection_unit = preload("res://scenes/combat/CombatPartySelectionUnit.tscn")
onready var grid = $UIBackground/PartySelectionGrid

var selected_party_unit_ids = []
var event_party_max_members : int

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# emitters
	self.connect("combat_party_selection_finished", relay, "_on_combat_party_selection_finished")
	# listeners
	relay.connect("combat_selecton_button_toggled", self, "_on_combat_selecton_button_toggled")
	relay.connect("combat_party_selection_finish_button_pressed", self, "_on_combat_party_selection_finish_button_pressed")
	

func init():
	# populate buttons
	for unit_id in root.game_data["main_data"]["party_unit_ids"]:
		var unit_data = root.game_data["unit_data"][unit_id]
		var ui_element = self.combat_selection_unit.instance()
		self.grid.add_child(ui_element)
		ui_element.init(unit_data)
	
	# get the max party count
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	self.event_party_max_members = int(current_event_data["event_party_max_members"])
	
	
	$PartyMemberCountLabel.text = str(len(selected_party_unit_ids)) + " / " + str(self.event_party_max_members)

func _on_combat_selecton_button_toggled(button):
	# add unit to selected party member list
	var unit_id = button.unit_data["unit_id"]
	if button.pressed and !selected_party_unit_ids.has(unit_id):
		selected_party_unit_ids.append(unit_id)
	if !button.pressed and selected_party_unit_ids.has(unit_id):
		selected_party_unit_ids.erase(unit_id)
		
	$PartyMemberCountLabel.text = str(len(selected_party_unit_ids)) + " / " + str(self.event_party_max_members)

func _on_combat_party_selection_finish_button_pressed():
	# if selected more than 0 and less than max allowed
	if len(self.selected_party_unit_ids) <= self.event_party_max_members:
		if len(self.selected_party_unit_ids) > 0:
			emit_signal("combat_party_selection_finished", self.selected_party_unit_ids)
			self.queue_free()