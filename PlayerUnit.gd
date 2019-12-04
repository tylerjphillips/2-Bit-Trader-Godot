extends Area2D

signal click_unit

export (int) var unit_movement_points = 4 setget set_unit_movement_points, get_unit_movement_points
export (int) var unit_movement_points_max = 4 setget set_unit_movement_points_max, get_unit_movement_points_max
export (int) var unit_health_points = 4 setget set_unit_health_points, get_unit_health_points
export (int) var unit_health_points_max = 4 setget set_unit_health_points_max, get_unit_health_points_max
export var unit_name = ""

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
	
	
	
func set_unit_movement_points(value):
     unit_movement_points = value
func get_unit_movement_points():
     return unit_movement_points
func set_unit_movement_points_max(value):
     unit_movement_points_max = value
func get_unit_movement_points_max():
     return unit_movement_points_max
func set_unit_health_points(value):
     unit_health_points = value
func get_unit_health_points():
     return unit_health_points
func set_unit_health_points_max(value):
     unit_health_points_max = value
func get_unit_health_points_max():
     return unit_health_points_max
	