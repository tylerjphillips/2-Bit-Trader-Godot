extends Area2D

signal click_unit

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	emit_signal("click_unit", self)
	


func _on_PlayerUnit_mouse_entered():
	return
	print("Mouse Entered")

func _on_PlayerUnit_mouse_exited():
	return
	print("Mouse Exited")
