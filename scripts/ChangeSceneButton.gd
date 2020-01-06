extends Button

export var new_scene_name = ""	# name of scene to change to

signal change_scene

func _ready():
	pass


func _on_ChangeSceneButton_button_up():
	if self.new_scene_name == "":
		print("ChangeSceneButton: no scene specified.")
	else:
		emit_signal("change_scene", new_scene_name)
