extends GridContainer

onready var unit_sidebar_asset = preload("res://scenes/combat/UnitSideBarButton.tscn") # unit prefab

onready var relay = get_node("/root/SignalRelay")
onready var root = get_tree().get_root().get_node("Root")	# reference to root game node

func _ready():
	# listeners
	relay.connect("unit_spawned", self, "_on_unit_spawned")

func _on_unit_spawned(unit):
	# initialize sidebar unit UI for those belonging to the player team
	if unit.unit_team == self.root.game_data["main_data"]["player_team"]:
		var sidebar_unit = unit_sidebar_asset.instance()
		self.add_child(sidebar_unit)
		sidebar_unit.init(unit)