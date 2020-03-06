extends ColorRect

export var max_width = 16
var unit

onready var relay = get_node("/root/SignalRelay")

func _ready():
	relay.connect("unit_xp_changed", self, "_on_unit_xp_changed")

func init(unit):
	self.unit = unit
	var width = float(unit.unit_xp) / max(1,unit.unit_xp_max) * self.max_width
	self.set_size(Vector2(width, self.get_size()[1]))

func _on_unit_xp_changed(unit):
	if self.unit == unit:
		var width = float(unit.unit_xp) / max(1,unit.unit_xp_max) * self.max_width
		self.set_size(Vector2(width, self.get_size()[1]))
