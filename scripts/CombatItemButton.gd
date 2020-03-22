extends TextureButton

signal unit_info_weapon_selected

var weapon_id

onready var relay = get_node("/root/SignalRelay")


func _ready():
	# emitters
	self.connect("unit_info_weapon_selected", relay, "_on_unit_info_weapon_selected")
	self.connect("button_up", self, "_on_unit_info_weapon_selected")
	
func init(unit, weapon_id):
	self.weapon_id = weapon_id
	var weapon_texture_path = unit.unit_weapon_data[weapon_id]["weapon_texture_path"]
	self.texture_normal = load(weapon_texture_path)
	
	# set the tooltip text to display flavor text and damages
	var tooltip_text = unit.unit_weapon_data[weapon_id].get("weapon_tooltip", "")
	for damage_type in unit.unit_weapon_data[weapon_id]["damage"]:
		tooltip_text += "\n" + damage_type + ": " + str(unit.unit_weapon_data[weapon_id]["damage"][damage_type])
	self.hint_tooltip = tooltip_text

func _on_unit_info_weapon_selected():
	emit_signal("unit_info_weapon_selected", self.weapon_id)