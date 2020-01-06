extends TextureButton

export(String, "0","1","2","3") var weapon_index # the weapon this button corresponds to

func _ready():
	pass # Replace with function body.



func _on_ItemButton_button_up():
	get_tree().call_group("tilemap", "_on_ItemButton_button_up", self.weapon_index)
	
func _on_unit_selected(unit):
	self.hide()
	var index = self.weapon_index
	if unit.unit_weapon_data.has(index):
		print("ItemButton"+index + " populated")
		self.show()
		self.hint_tooltip = unit.unit_weapon_data[index].get("weapon_tooltip", "")
	
