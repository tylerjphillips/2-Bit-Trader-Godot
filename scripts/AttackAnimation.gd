extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "_on_animation_finished")
	
func init(frame_paths):
	# load animation from texture file paths
	self.frames.clear_all()
	for frame_path in frame_paths:
		self.frames.add_frame("default", load(frame_path))

func _on_animation_finished():
	self.queue_free()
