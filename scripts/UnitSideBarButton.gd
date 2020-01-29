extends Button

signal unit_sidebar_pressed
var unit;	# must be assigned to a unit. Corresponds to the

func init(unit):
	self.unit = unit
	self.icon = load(unit.unit_texture_path)
	self.text = unit.unit_name

func _on_UnitSideBarButton_button_up():
	emit_signal("unit_sidebar_pressed", self.unit)
	
func _on_kill_unit(killed_unit):
	if killed_unit == self.unit:
		self.queue_free()