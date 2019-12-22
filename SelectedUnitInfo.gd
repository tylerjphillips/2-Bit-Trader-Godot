extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_unit_selected(unit):
	print(unit.name + " selected")
	self.show()

func _on_unit_deselected(unit):
	print(unit.name + " deselected")
	self.hide()