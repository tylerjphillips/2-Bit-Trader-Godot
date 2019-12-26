extends TextureButton

export var weapon_index = 0 # the weapon this button corresponds to. must be typecast to a string

func _ready():
	pass # Replace with function body.



func _on_ItemButton_button_up():
	get_tree().call_group("tilemap", "_on_ItemButton_button_up", self.weapon_index)
	
func _on_unit_selected(unit):
	self.hide()
	var index = str(self.weapon_index)
	if unit.unit_weapon_data.has(index):
		print("ItemButton"+index + " populated")
		self.show()
		self.hint_tooltip = unit.unit_weapon_data[index].get("weapon_tooltip", "")
	
