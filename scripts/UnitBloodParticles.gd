extends CPUParticles2D

onready var directions_to_degrees = {"north":270, "east":0, "south":90, "west":180, "none":0}

func _ready():
	get_node("BloodParticleTimer").connect("timeout", self, "_on_particle_timer_end")

func emit(direction):
	self.rotation_degrees = directions_to_degrees[direction]
	self.emitting = true
	print("awsdawjbhdkljawnbdjklhawbd", direction)
	
func _on_particle_timer_end():
	self.queue_free()