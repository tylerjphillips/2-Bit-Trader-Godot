extends Node2D
var health_icon = preload("res://scenes/combat/Health.tscn")

const health_container_width = 32

func init(unit_health, unit_health_max):
	generate_health_bar(unit_health, unit_health_max)

func _on_unit_health_changed(unit_health, unit_health_max):
	generate_health_bar(unit_health, unit_health_max)
	
func generate_health_bar(unit_health, unit_max_health):
	for i in self.get_children():
		i.queue_free()
	for index in range(unit_max_health):
		var health = health_icon.instance();
		self.add_child(health)
		health.position = self.position + Vector2(8 * index, 0);
		if index + 1 > unit_health: 
			health.frame = 1