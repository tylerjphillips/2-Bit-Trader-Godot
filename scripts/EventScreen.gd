extends Node

signal change_scene # (old_scene_name, new_scene_name)

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")


onready var change_scene_button = get_node("ChangeSceneButton")	
onready var event_image = get_node("EventImage")
onready var event_choice_container = get_node("EventScrollContainer/EventChoiceContainer")
onready var event_dialogue = get_node("EventDialogueLabel")

onready var event_choice_asset = preload("res://scenes/event/EventChoiceButton.tscn")

func _ready():
	assert root
	assert change_scene_button
	assert event_image
	assert event_choice_container
	assert event_dialogue
	
	change_scene_button.connect("change_scene", self, "change_scene")
	event_dialogue.connect("event_dialogue_typing_ended", self, "_on_event_dialogue_typing_ended")
	
	# emitters
	self.connect("change_scene", relay, "_on_change_scene")
	
	

func init(game_data):
	self.update_dialogue_text()
	
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var event_image_path = current_event_data["event_image_path"]
	update_event_image(event_image_path)
	

func update_event_image(image_path):
	event_image.texture = load(image_path)

func update_dialogue_text():
	#updates event dialogue text label to current event's current dialogue
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var choice_data = current_event_data["event_choice_data"]
	var dialogue_data = current_event_data["event_dialogue_data"]
	var event_current_dialogue_id = current_event_data["event_current_dialogue_id"]
	
	var current_dialogue_data = dialogue_data[event_current_dialogue_id]
	var dialogue_bbcode = current_dialogue_data["dialogue_bbcode"]
	event_dialogue.set_typewriter_bbcode(dialogue_bbcode)
	
func change_scene(new_scene_name):
	emit_signal("change_scene", "event_screen", new_scene_name)

func _on_event_dialogue_typing_ended():
	print("EventScreen: end of dialogue typing")
	populate_choices()
	
func populate_choices():
	# create all the choice buttons for the current dialogue
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_event_data = self.root.game_data["event_data"][current_event_id]
	var choice_data = current_event_data["event_choice_data"]
	
	var event_current_dialogue_id = current_event_data["event_current_dialogue_id"]
	var current_dialogue_data = current_event_data["event_dialogue_data"][event_current_dialogue_id]
	var choice_ids = current_dialogue_data["choice_ids"]
	for choice_id in choice_ids:
		print("EventScreen: populating choice: ",choice_data[choice_id])
		var event_choice = self.event_choice_asset.instance()
		self.event_choice_container.add_child(event_choice)
		event_choice.init(choice_data[choice_id])
		event_choice.connect("event_choice_selected", self, "_on_event_choice_selected")
		
func _on_event_choice_selected(selected_choice_data):
	print("EventScreen: choice selected: ",selected_choice_data)
	# remove existing choices
	for choice in self.event_choice_container.get_children():
		choice.queue_free()
	# update event image
	update_event_image(selected_choice_data["set_event_image_path"])
	
	# handle rewards
	if selected_choice_data["choice_rewards"].has("region_id"):
		# region change
		self.root.game_data["main_data"]["current_region_id"] = selected_choice_data["choice_rewards"]["region_id"]	
	if selected_choice_data["choice_rewards"].has("location_id"):
		# location change
		self.root.game_data["main_data"]["current_location_id"] = selected_choice_data["choice_rewards"]["location_id"]	
	if selected_choice_data["choice_rewards"].has("gold"):
		# gold
		self.root.game_data["main_data"]["gold"] += selected_choice_data["choice_rewards"]["gold"]
	if selected_choice_data["choice_rewards"].has("bonus_xp"):
		# bonus xp
		self.root.game_data["main_data"]["bonus_xp"] += selected_choice_data["choice_rewards"]["bonus_xp"]	
	if selected_choice_data["choice_rewards"].has("items"):
		# items
		for item_id in selected_choice_data["choice_rewards"]["items"]:
			self.root.game_data["main_data"]["player_items"][item_id] = selected_choice_data["choice_rewards"]["items"]
	if selected_choice_data["choice_rewards"].has("unit_ids"):
		# units
		for unit_id in selected_choice_data["choice_rewards"]["unit_ids"]:
			if !self.root.game_data["main_data"]["party_unit_ids"].has(unit_id):
				self.root.game_data["main_data"]["party_unit_ids"].push_back(unit_id)
	
	if selected_choice_data["choice_starts_combat"]:
		# start combat if possible
		self.change_scene("combat_screen")
		var current_event_id = self.root.game_data["main_data"]["current_event_id"]
		self.root.game_data["event_data"][current_event_id]["event_current_dialogue_id"] = selected_choice_data["dialogue_id"]
	elif selected_choice_data["choice_returns_to_overworld"]:
		# return to overworld if possible
		self.end_event()
	else:
		# continue dialogue
		var current_event_id = self.root.game_data["main_data"]["current_event_id"]
		self.root.game_data["event_data"][current_event_id]["event_current_dialogue_id"] = selected_choice_data["dialogue_id"]
		update_dialogue_text()
		
		
func end_event():
	var current_location_id = self.root.game_data["main_data"]["current_location_id"]
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	var current_location_data = self.root.game_data["overworld_data"][current_location_id]
	
	# reset the event to reuse it if necessary, and mark the location as completed
	self.root.game_data["overworld_data"][current_location_id]["location_event_complete"] = true
	self.root.game_data["event_data"][current_event_id]["event_current_dialogue_id"] = self.root.game_data["event_data"][current_event_id]["event_start_dialouge_id"]

	self.change_scene("overworld_screen")
		
####### Serialization ########

func update_all_unit_data():
	for unit in get_tree().get_nodes_in_group("units"):
		unit.update_global_data_entry()