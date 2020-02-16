extends AnimationPlayer

onready var relay = $"/root/SignalRelay"

func _ready():
	relay.connect("unit_attacks_unit", self, "_on_unit_attacks_unit")
	
func _on_unit_attacks_unit(attacking_unit, weapon_data, attacked_unit, damage_tile_index):
	self.play("ScreenShake")
