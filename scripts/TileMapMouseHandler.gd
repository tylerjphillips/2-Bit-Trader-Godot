extends Area2D

var mouse_inside = false

signal tilemap_left_click
signal tilemap_right_click
signal tilemap_hover

func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	
func _on_mouse_entered():
	self.mouse_inside = true

func _on_mouse_exited():
	self.mouse_inside = false

func _unhandled_input(event):
	if self.mouse_inside:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				emit_signal("tilemap_left_click")
			if event.button_index == BUTTON_RIGHT:
				emit_signal("tilemap_right_click")
				

func _process(delta):
	if self.mouse_inside:
		emit_signal("tilemap_hover")