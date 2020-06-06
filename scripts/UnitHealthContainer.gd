extends Node2D
var health_icon = preload("res://scenes/combat/Health.tscn")
var status_icon = preload("res://scenes/combat/Status.tscn")

const health_container_width = 32

func init(unit_health, unit_health_max, unit_status_effects):
	generate_health_bar(unit_health, unit_health_max, 0, unit_status_effects)

func _on_unit_health_changed(unit_health, unit_health_max):
	generate_health_bar(unit_health, unit_health_max)
	
func generate_health_bar(unit_health : int, unit_max_health : int, damage_preview = 0, unit_status_effects = {}, unit_applied_status_effects = {}):
	# free existing health bars
	for i in self.get_children():
		i.queue_free()
		
	var index = 0	
	# generate a bar showing green icons for remaining health, and the rest are marked out
	for i in range(unit_max_health):
		var health = health_icon.instance();
		self.add_child(health)
		health.position = self.position + Vector2(8 * (index - (int(index / 4) * 4)) , int(index / 4) * 9);
		
		# marked out health
		if (index + 1 > unit_health): 
			health.frame = 1
		# damage preview animations
		var remaining_health = unit_health - damage_preview
		if ((index + 1 <= unit_health) and (index + 1 > remaining_health)): 
			health.get_node("DamagePreviewPlayer").play("DamagePreview")
		
		index += 1
			
	for status_id in unit_status_effects:
		var status = status_icon.instance();
		self.add_child(status)
		status.texture = load(unit_status_effects[status_id]["status_image"])
		status.position = self.position + Vector2(8 * (index - (int(index / 4) * 4)) , int(index / 4) * 9);
		index += 1
		
	for status_id in unit_applied_status_effects:
		var status = status_icon.instance();
		self.add_child(status)
		status.texture = load(unit_applied_status_effects[status_id]["status_image"])
		status.position = self.position + Vector2(8 * (index - (int(index / 4) * 4)) , int(index / 4) * 9);
		status.get_node("DamagePreviewPlayer").play("DamagePreview")
		index += 1