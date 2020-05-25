extends TextureButton

signal unit_info_weapon_selected

var weapon_id

onready var item_durability_label = $ItemDurabilityLabel

onready var relay = get_node("/root/SignalRelay")


func _ready():
	# emitters
	self.connect("unit_info_weapon_selected", relay, "_on_unit_info_weapon_selected")
	self.connect("button_up", self, "_on_unit_info_weapon_selected")
	
func init(unit, weapon_id):
	self.weapon_id = weapon_id
	var weapon_texture_path = unit.unit_weapon_data[weapon_id]["weapon_texture_path"]
	self.texture_normal = load(weapon_texture_path)
	
	# set the tooltip text to display flavor text
	var tooltip_text = unit.unit_weapon_data[weapon_id].get("weapon_tooltip", "")
	self.hint_tooltip = tooltip_text
	
	# set item durability text
	if unit.unit_weapon_data[weapon_id].has("item_durability"):
		var item_durability = unit.unit_weapon_data[weapon_id]["item_durability"]
		var item_durability_max = unit.unit_weapon_data[weapon_id]["item_durability_max"]
		self.item_durability_label.text = str(item_durability) + "/" +  str(item_durability_max)
		self.item_durability_label.show()

func _on_unit_info_weapon_selected():
	emit_signal("unit_info_weapon_selected", self.weapon_id)