extends Node2D

func _ready():
	pass

func init(unit, start_pos : Vector2, end_pos : Vector2):
	$PushPreviewLine.add_point(Vector2(0, 0))
	$PushPreviewLine.add_point(Vector2(0, 0) + start_pos - end_pos)
	$PushPreviewPlayer.play("PushPreview")
	$PushPreviewUnitSprite.texture = load(unit.unit_texture_path)