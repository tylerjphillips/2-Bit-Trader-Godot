extends Node

signal change_scene
	# caravans
signal caravan_destination_reached # (to_location_id)
signal caravan_started_traveling # (to_location_id)

signal day_ended

signal overworld_location_button_up

	# unit signals
signal unit_spawned # (unit)
signal unit_selected # (unit)
signal unit_deselected # (unit)
signal unit_moved	# (unit, previous_tile_index, tile_index, cost)
signal unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data)
signal unit_attacks_unit(attacking_unit, attacking_unit_weapon_data, attacked_unit, damage_tile_index)
signal unit_collides_unit # (attacking_unit, colliding_unit, collision_count, collided_unit)
signal unit_sidebar_pressed # (unit)
signal unit_clicked # (unit)
signal unit_health_changed # (unit_health_points, unit_health_points_max)
signal unit_killed # (killed_unit, killer_unit)
signal unit_mouse_entered # (unit)
signal unit_mouse_exited # (unit)
signal unit_boss_killed(boss_unit)
signal unit_level_changed # (unit)
signal unit_xp_changed # (unit)
signal unit_leveled_up # (unit)
	# recruitment screen
signal unit_recruitment_failed(unit_data)
signal unit_recruitment_succeeded(unit_data)
	# tilemap/combat
signal team_start_turn # (team)
signal team_end_turn # (team)
signal round_started
signal round_ended
	# damage previews
signal tilemap_damage_preview # (damage_pattern)

signal combat_victory
signal combat_defeat

signal unit_info_weapon_selected # (weapon_id)

signal undo_button_pressed
signal end_turn_button_pressed
	# party screen
signal party_member_button_pressed(button, unit_data)
signal party_take_item_button_up # (item_button)
signal party_give_item_button_up # (item_button)
	# event screen
signal event_choice_selected
signal event_dialogue_typing_ended

	# shop screen
signal shop_confirm_button_up # (item button)
signal shop_buy_item_button_up # (item_button)
signal shop_sell_item_button_up # (item_button)
signal shop_buy_item_failed
signal shop_buy_item_succeeded
signal shop_sell_item_succeeded
signal gold_amount_changed

signal audio_finished # (path)
	# loading screen
signal load_campaign_button_pressed # (campaign_data)
signal campaign_button_up # (campaign_data)

func _ready():
	pass
	
func _on_unit_spawned(unit):
	emit_signal("unit_spawned", unit)
func _on_unit_clicked(unit):
	print("Relay: unit clicked")
	emit_signal("unit_clicked", unit)
func _on_unit_killed(killed_unit, killer_unit):
	print("Relay: unit killed: ", killed_unit.unit_name, " killed by ", killer_unit.unit_name)
	emit_signal("unit_killed", killed_unit, killer_unit)
func _on_unit_selected(unit):
	# print("Relay: unit selected")
	emit_signal("unit_selected", unit)
func _on_unit_deselected(unit):
	# print("Relay: unit deselected")
	emit_signal("unit_deselected", unit)
func _on_unit_moved(unit, previous_tile_index, tile_index, movement_cost):
	# print("Relay: unit has moved")
	emit_signal("unit_moved", unit, previous_tile_index, tile_index, movement_cost)
func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	emit_signal("unit_attacks_tile", attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data)
func _on_unit_attacks_unit(attacking_unit, damage_pattern, attacked_unit, damage_tile_index):
	print("Relay: unit attacks")
	emit_signal("unit_attacks_unit", attacking_unit, damage_pattern, attacked_unit, damage_tile_index)
func _on_unit_collides_unit(attacking_unit, colliding_unit, collision_count, collided_unit): 
	# print("Relay: unit collides with unit")
	emit_signal("unit_collides_unit",attacking_unit, colliding_unit, collision_count, collided_unit)
func _on_unit_mouse_entered(unit):
	emit_signal("unit_mouse_entered", unit)
func _on_unit_mouse_exited(unit):
	emit_signal("unit_mouse_exited", unit)
func _on_unit_boss_killed(boss_unit):
	# print("SignalRelay: Boss unit killed")
	emit_signal("unit_boss_killed", boss_unit)
	
func _on_unit_level_changed(unit):
	emit_signal("unit_level_changed", unit)
func _on_unit_xp_changed(unit):
	emit_signal("unit_xp_changed", unit)
func _on_unit_leveled_up(unit):
	emit_signal("unit_leveled_up", unit)

func _on_unit_recruitment_failed(unit_data):
	# print("Relay: recruitment failed")
	emit_signal("unit_recruitment_failed", unit_data)
func _on_unit_recruitment_succeeded(unit_data):
	# print("Relay: recruitment succeeded")
	emit_signal("unit_recruitment_succeeded", unit_data)

func _on_unit_sidebar_pressed(unit):
	# print("Relay: unit sidebar pressed")
	emit_signal("unit_sidebar_pressed", unit)
func _on_unit_info_weapon_selected(weapon_id):
	# print("Relay: unit_info_weapon_selected")
	emit_signal("unit_info_weapon_selected", weapon_id)

func _on_undo_button_pressed(undo_unit, undo_unit_state):
	emit_signal("undo_button_pressed", undo_unit, undo_unit_state)
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
	
func _on_tilemap_damage_preview(damage_pattern):
	emit_signal("tilemap_damage_preview", damage_pattern)	
	
func _on_combat_victory():
	print("SignalRelay: Combat Victory")
	emit_signal("combat_victory")
func _on_combat_defeat():
	print("SignalRelay: Combat Loss")
	emit_signal("combat_defeat")
	
func _on_party_member_button_pressed(button, unit_data):
	emit_signal("party_member_button_pressed", button, unit_data)

func _on_party_take_item_button_up(item_button):
	# print("Relay: take item button pressed")
	emit_signal("party_take_item_button_up", item_button)
func _on_party_give_item_button_up(item_button):
	# print("Relay: give item button pressed")
	emit_signal("party_give_item_button_up", item_button)

func _on_day_ended():
	emit_signal("day_ended")

func _on_caravan_started_traveling(to_location_id):
	print("Relay: caravan started traveling")
	emit_signal("caravan_started_traveling", to_location_id)
func _on_caravan_destination_reached(to_location_id):
	print("Relay: caravan destination reached")
	emit_signal("caravan_destination_reached", to_location_id)
	
func _on_overworld_location_button_up(location_id):
	emit_signal("overworld_location_button_up", location_id)

func _on_shop_confirm_button_up(item_button):
	emit_signal("shop_confirm_button_up", item_button)
func _on_shop_buy_item_button_up(item_button):
	emit_signal("shop_buy_item_button_up", item_button)
func _on_shop_sell_item_button_up(item_button):
	emit_signal("shop_sell_item_button_up", item_button)
func _on_shop_buy_item_failed():
	emit_signal("shop_buy_item_failed")
func _on_shop_buy_item_succeeded():
	emit_signal("shop_buy_item_succeeded")
func _on_shop_sell_item_succeeded():
	emit_signal("shop_sell_item_succeeded")

func _on_gold_amount_changed():
	emit_signal("gold_amount_changed")

func _on_audio_finished(audio_path):
	emit_signal("audio_finished", audio_path)
	
	
func _on_load_campaign_button_pressed(campaign_data):
	emit_signal("load_campaign_button_pressed", campaign_data)
func _on_campaign_button_up(campaign_data):
	emit_signal("campaign_button_up", campaign_data)