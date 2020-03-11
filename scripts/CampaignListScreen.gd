extends Node

var campaign_info_module = preload("res://scenes/new_campaign/CampaignInfoModule.tscn")
onready var campaign_container = $ScrollContainer/GridContainer
onready var campaign_description_label = $CampaignDescLabel

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	# listeners
	relay.connect("campaign_button_up", self, "_on_campaign_button_up")
	
func init(game_data):
	for campaign_name in game_data["campaign_data"]:
		var info_module = self.campaign_info_module.instance()
		campaign_container.add_child(info_module)
		info_module.init(game_data["campaign_data"][campaign_name])
		
func _on_campaign_button_up(campaign_data):
	self.campaign_description_label.text = campaign_data["campaign_description"]