extends TileMap

func _ready():
	pass

func create_placement_tiles(placement_tiles):
	self.clear()
	for tile_index in placement_tiles:
		self.set_cell(tile_index[0], tile_index[1], 2)

func create_movement_tiles(bfs_results):
	self.clear()
	for tile_index in bfs_results:
		self.set_cell(tile_index.x, tile_index.y, 0)

func clear_movement_tiles():
	self.clear()

func create_attack_tiles(attack_pattern : Dictionary):
	self.clear()
	for tile_index in attack_pattern:
		self.set_cell(tile_index.x, tile_index.y, 1)

func create_damage_tiles(attack_pattern : Dictionary, damage_pattern : Dictionary):
	self.clear()
	for tile_index in attack_pattern:
		self.set_cell(tile_index.x, tile_index.y, 1)
	for tile_index in damage_pattern:
		self.set_cell(tile_index.x, tile_index.y, 0)

func clear_attack_tiles():
	self.clear()