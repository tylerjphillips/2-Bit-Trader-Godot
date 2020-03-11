extends Button

var campaign_data

signal load_campaign_button_pressed # (campaign_data)

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")

func _ready():
	self.connect("button_up", self, "_on_LoadCampaignButton_button_up")
	# listeners
	relay.connect("campaign_button_up", self, "_on_campaign_button_up")
	# emitters
	self.connect("load_campaign_button_pressed", relay, "_on_load_campaign_button_pressed")

func _on_campaign_button_up(campaign_data):
	self.show()
	self.campaign_data = campaign_data

func _on_LoadCampaignButton_button_up():
	emit_signal("load_campaign_button_pressed", self.campaign_data)
