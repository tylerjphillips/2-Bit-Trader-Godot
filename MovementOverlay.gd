extends TileMap

func _ready():
	pass

func _on_create_movement_tiles(bfs_results):
	self.clear()
	for tile_index in bfs_results:
		self.set_cell(tile_index.x, tile_index.y, 0)

func _on_clear_movement_tiles():
	self.clear()

func _on_create_attack_tiles(tile_indexes : Array):
	self.clear()
	for tile_index in tile_indexes:
		self.set_cell(tile_index.x, tile_index.y, 1)

func _on_clear_attack_tiles():
	self.clear()