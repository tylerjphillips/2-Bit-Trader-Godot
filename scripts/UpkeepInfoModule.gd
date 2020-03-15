extends Control

onready var upkeep_label = $UpkeepLabel

onready var root = get_tree().get_root().get_node("Root")

func _ready():
	var party_unit_ids = self.root.game_data["main_data"]["party_unit_ids"]
	var total_upkeep_cost = 0
	for unit_id in party_unit_ids:
		var unit_upkeep_cost = self.root.game_data["unit_data"][unit_id]["unit_upkeep_cost"]
		total_upkeep_cost += unit_upkeep_cost
	self.upkeep_label.text = str(total_upkeep_cost)