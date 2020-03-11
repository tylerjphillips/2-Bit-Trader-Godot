extends Control

signal campaign_button_up # (campaign_data)

onready var campaign_button = $CampaignButton

onready var root = get_tree().get_root().get_node("Root")
onready var relay = get_node("/root/SignalRelay")

var campaign_data;

func _ready():
	# emitters
	self.connect("campaign_button_up", relay, "_on_campaign_button_up")
	# listeners
	campaign_button.connect("button_up", self, "_on_campaign_button_up")

func init(campaign_data):
	self.campaign_data = campaign_data
	campaign_button.text = campaign_data["campaign_name"]
	

func _on_campaign_button_up():
	emit_signal("campaign_button_up", campaign_data)
