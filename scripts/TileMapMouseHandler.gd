extends Area2D

var mouse_inside = false
var disabled = false

signal tilemap_left_click
signal tilemap_right_click
signal tilemap_hover

onready var relay = get_node("/root/SignalRelay")

func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	
	# listeners
	relay.connect("combat_defeat", self, "_on_combat_defeat")
	relay.connect("combat_victory", self, "_on_combat_victory")
	
func _on_mouse_entered():
	self.mouse_inside = true

func _on_mouse_exited():
	self.mouse_inside = false
	
func _on_combat_defeat():
	self.disabled = true
func _on_combat_victory():
	self.disabled = true	

func _unhandled_input(event):
	# grab the mouse input events and send them to the tilemap
	if !self.disabled:
		if self.mouse_inside:
			if event is InputEventMouseButton and event.is_pressed():
				if event.button_index == BUTTON_LEFT:
					emit_signal("tilemap_left_click")
				if event.button_index == BUTTON_RIGHT:
					emit_signal("tilemap_right_click")

func _process(delta):
	if self.mouse_inside:
		emit_signal("tilemap_hover")