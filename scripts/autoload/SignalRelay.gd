extends Node

signal change_scene

signal caravan_destination_reached # (to_location_id)
signal caravan_started_traveling # (to_location_id)

signal overworld_location_button_up

signal unit_spawned # (unit)
signal unit_selected # (unit)
signal unit_deselected # (unit)
signal unit_moved	# (unit, tile_index, cost)
signal unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data)
signal unit_attacks_unit(attacking_unit, attacking_unit_weapon_data, attacked_unit, damage_tile_index)
signal unit_collides_unit # (attacking_unit, affected_unit, collision_count, collided_unit)
signal unit_sidebar_pressed # (unit)
signal unit_clicked # (unit)
signal unit_health_changed # (unit_health_points, unit_health_points_max)
signal unit_killed # (unit)
signal unit_mouse_entered # (unit)
signal unit_mouse_exited # (unit)
signal unit_recruitment_failed(unit_data)
signal unit_recruitment_succeeded(unit_data)

signal team_start_turn # (team)
signal team_end_turn # (team)
signal round_started
signal round_ended

signal unit_info_weapon_selected # (weapon_id)

signal end_turn_button_pressed

signal party_member_button_pressed(button, unit_data)
signal party_take_item_button_up # (item_button)
signal party_give_item_button_up # (item_button)

signal event_choice_selected
signal event_dialogue_typing_ended

signal shop_buy_item_button_up # (item_button)
signal shop_sell_item_button_up # (item_button)
signal shop_buy_item_failed
signal shop_buy_item_succeeded
signal shop_sell_item_succeeded

signal audio_finished # (path)

func _ready():
	pass
	
func _on_unit_spawned(unit):
	emit_signal("unit_spawned", unit)
func _on_unit_clicked(unit):
	print("Relay: unit clicked")
	emit_signal("unit_clicked", unit)
func _on_unit_killed(unit):
	print("Relay: unit killed")
	emit_signal("unit_killed", unit)
func _on_unit_selected(unit):
	print("Relay: unit selected")
	emit_signal("unit_selected", unit)
func _on_unit_deselected(unit):
	print("Relay: unit deselected")
	emit_signal("unit_deselected", unit)
func _on_unit_moved(unit, tile_index, movement_cost):
	print("Relay: unit has moved")
	emit_signal("unit_moved", unit, tile_index, movement_cost)
func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	emit_signal("unit_attacks_tile", attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data)
func _on_unit_attacks_unit(attacking_unit, weapon_data, attacked_unit, damage_tile_index):
	print("Relay: unit attacks")
	emit_signal("unit_attacks_unit", attacking_unit, weapon_data, attacked_unit, damage_tile_index)
func _on_unit_collides_unit(attacking_unit, affected_unit, collision_count, collided_unit): 
	print("Relay: unit collides with unit")
	emit_signal("unit_collides_unit",attacking_unit, affected_unit, collision_count, collided_unit)
func _on_unit_mouse_entered(unit):
	emit_signal("unit_mouse_entered", unit)
func _on_unit_mouse_exited(unit):
	emit_signal("unit_mouse_exited", unit)
func _on_unit_recruitment_failed(unit_data):
	print("Relay: recruitment failed")
	emit_signal("unit_recruitment_failed", unit_data)
func _on_unit_recruitment_succeeded(unit_data):
	print("Relay: recruitment succeeded")
	emit_signal("unit_recruitment_succeeded", unit_data)

func _on_unit_sidebar_pressed(unit):
	print("Relay: unit sidebar pressed")
	emit_signal("unit_sidebar_pressed", unit)
func _on_unit_info_weapon_selected(weapon_id):
	print("Relay: unit_info_weapon_selected")
	emit_signal("unit_info_weapon_selected", weapon_id)

func _on_end_turn_button_pressed():
	emit_signal("end_turn_button_pressed")
func _on_team_start_turn(team):
	emit_signal("team_start_turn", team)
func _on_team_end_turn(team):
	emit_signal("team_end_turn", team)
	
func _on_round_started():
	emit_signal("round_started")
func _on_round_ended():
	emit_signal("round_ended")
	
func _on_party_member_button_pressed(button, unit_data):
	emit_signal("party_member_button_pressed", button, unit_data)

func _on_party_take_item_button_up(item_button):
	print("Relay: take item button pressed")
	emit_signal("party_take_item_button_up", item_button)
func _on_party_give_item_button_up(item_button):
	print("Relay: give item button pressed")
	emit_signal("party_give_item_button_up", item_button)

func _on_caravan_started_traveling(to_location_id):
	print("Relay: caravan started traveling")
	emit_signal("caravan_started_traveling", to_location_id)
func _on_caravan_destination_reached(to_location_id):
	print("Relay: caravan destination reached")
	emit_signal("caravan_destination_reached", to_location_id)
	
func _on_overworld_location_button_up(location_id):
	emit_signal("overworld_location_button_up", location_id)
	
func _on_shop_buy_item_button_up(item_button):
	emit_signal("shop_buy_item_button_up", item_button)
	print("Relay: buying "+str(item_button.value))
func _on_shop_sell_item_button_up(item_button):
	emit_signal("shop_sell_item_button_up", item_button)
	print("Relay: selling "+str(item_button.value))
func _on_shop_buy_item_failed():
	emit_signal("shop_buy_item_failed")
func _on_shop_buy_item_succeeded():
	emit_signal("shop_buy_item_succeeded")
func _on_shop_sell_item_succeeded():
	emit_signal("shop_sell_item_succeeded")
	
func _on_audio_finished(audio_path):
	emit_signal("audio_finished", audio_path)