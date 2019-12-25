extends TextureButton

export var weapon_index = 0

func _ready():
	pass # Replace with function body.



func _on_ItemButton_button_up():
	get_tree().call_group("tilemap", "_on_ItemButton_button_up", self.weapon_index)
