extends Node2D
var health_icon = preload("res://scenes/combat/Health.tscn")

const health_container_width = 32

func init(unit_health, unit_health_max):
	generate_health_bar(unit_health, unit_health_max)

func _on_unit_health_changed(unit_health, unit_health_max):
	generate_health_bar(unit_health, unit_health_max)
	
func generate_health_bar(unit_health : int, unit_max_health : int, damage_preview = 2):
	# free existing health bars
	for i in self.get_children():
		i.queue_free()
	# generate a bar showing green icons for remaining health, and the rest are marked out
	for index in range(unit_max_health):
		var health = health_icon.instance();
		self.add_child(health)
		health.position = self.position + Vector2(8 * index, 0);
		
		# marked out health
		if (index + 1 > unit_health): 
			health.frame = 1
		# damage preview animations
		var remaining_health = unit_health - damage_preview
		if ((index + 1 <= unit_health) and (index + 1 > remaining_health)): 
			health.get_node("DamagePreviewPlayer").play("DamagePreview")