extends ColorRect

export var max_width = 16
export var low_color = Color(.7,.7,1)
export var high_color = Color(0,0,1)
var unit

onready var xp_tween = get_node("XPTween")

onready var relay = get_node("/root/SignalRelay")

func _ready():
	relay.connect("unit_xp_changed", self, "_on_unit_xp_changed")

func init(unit):
	self.unit = unit
	interpolate_xp()
	
func interpolate_xp():
	var new_width = float(unit.unit_xp) / max(1,unit.unit_xp_max) * float(self.max_width)
	var new_size = Vector2(new_width, self.get_size()[1])
	var new_color = lerp(low_color, high_color, float(unit.unit_xp) / max(1,unit.unit_xp_max))
	self.set_size(new_size)
	xp_tween.interpolate_property(self, "color", self.color, new_color, 1 ,Tween.TRANS_LINEAR, Tween.EASE_IN)
	xp_tween.start()

func _on_unit_xp_changed(unit):
	if self.unit == unit:
		interpolate_xp()
