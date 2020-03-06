extends Label

var damage = 0 # used for damage stacking

func _ready():
	$DamageTextAnimation.connect("animation_finished", self, "_on_animation_finished")

func init(damage : int):
	self.show()
	self.damage += damage
	self.set_text(str(self.damage))
	if self.damage < 0:
		$DamageTextAnimation.play("HealTextRise")
	if self.damage > 0:
		$DamageTextAnimation.play("DamageTextRise")
	if self.damage == 0:
		self.set_text("Resisted")
		$DamageTextAnimation.play("NoDamageTextRise")

func _on_animation_finished(anim_name):
	self.damage = 0
	self.hide()