extends Area2D

signal settings_button_clicked

onready var settings_modal = $SettingsModal
onready var close_button = $SettingsModal/UIBackground/CloseButton

func _ready():
	close_button.connect("button_up", self, "close_settings_modal")

func open_settings_modal():
	$SettingsModal.show()
	get_tree().paused = true
func close_settings_modal():
	$SettingsModal.hide()
	get_tree().paused = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	print("Click")
	emit_signal("settings_button_clicked")
	open_settings_modal()