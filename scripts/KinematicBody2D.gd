extends KinematicBody2D
func _ready():
	set_process_input(true)

func _input_event(viewport, event, shape_idx):
	print("hi")
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.pressed:
		print("Clicked")
		return(self) # returns a reference to this node