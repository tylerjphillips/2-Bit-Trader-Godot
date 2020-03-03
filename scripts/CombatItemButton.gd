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
	self.hint_tooltip = unit.unit_weapon_data[weapon_id].get("weapon_tooltip", "")
	var weapon_texture_path = unit.unit_weapon_data[weapon_id]["weapon_texture_path"]
	self.texture_normal = load(weapon_texture_path)

func _on_unit_info_weapon_selected():
	emit_signal("unit_info_weapon_selected", self.weapon_id)