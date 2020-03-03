extends Button

signal unit_sidebar_pressed
var unit;	# must be assigned to a unit. Corresponds to the

onready var relay = get_node("/root/SignalRelay")

func _ready():
	# emitters
	self.connect("unit_sidebar_pressed", relay, "_on_unit_sidebar_pressed")
	# listeners
	relay.connect("unit_killed", self, "_on_unit_killed")

func init(unit):
	self.unit = unit
	self.icon = load(unit.unit_texture_path)
	self.text = unit.unit_name

func _on_UnitSideBarButton_button_up():
	emit_signal("unit_sidebar_pressed", self.unit)
	
func _on_unit_killed(killed_unit, killer_unit):
	if killed_unit == self.unit:
		self.queue_free()