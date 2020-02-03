extends Node2D
var health_icon = preload("res://scenes/combat/Health.tscn")
const health_width = 10

func init(unit_health, unit_health_max):
	for index in range(unit_health_max):
		var health = health_icon.instance();
		self.add_child(health)
		health.position = self.position + Vector2(health_width * index, 0);
		if index + 1 > unit_health:
			health.frame = 1

func _on_unit_health_changed(unit_health, unit_health_max):
	for i in self.get_children():
		i.queue_free()
	for index in range(unit_health_max):
		var health = health_icon.instance();
		self.add_child(health)
		health.position = self.position + Vector2(health_width * index, 0);
		if index + 1 > unit_health: 
			health.frame = 1

