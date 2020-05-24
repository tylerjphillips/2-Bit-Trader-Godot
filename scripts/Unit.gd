extends Area2D

# signals
signal unit_spawned # (unit)
signal unit_health_changed # (unit_health_points, unit_health_points_max)
signal unit_killed # (killed_unit, killer_unit)
signal unit_boss_killed # (unit)
signal unit_mouse_entered #(unit)
signal unit_mouse_exited #(unit)

signal unit_level_changed # (unit)
signal unit_xp_changed # (unit)
signal unit_leveled_up # (unit)
signal unit_item_broke # (unit, item_id)

# ui indicators
onready var health_bar = get_node("HealthContainer")

onready var move_indicator = get_node("MoveIndicator")
onready var team_indicator = get_node("TeamIndicator")
onready var attack_indicator = get_node("AttackIndicator")
onready var unit_sprite = get_node("UnitSprite")
onready var xp_bar = get_node("Node2D/UnitXPBar")
onready var floating_damage_text = get_node("UnitDamageFloatingText")
onready var levelup_particles = get_node("UnitLevelUpParticles")

# attacking animations
onready var directions_to_unit_animations = {
	"north":$NorthAttackAnimation,
	"south":$SouthAttackAnimation,
	"east":$EastAttackAnimation,
	"west":$WestAttackAnimation,
}

# unit properties
		# movement
export (int) var unit_movement_points = 4 setget set_unit_movement_points, get_unit_movement_points
export (int) var unit_movement_points_max = 4 setget set_unit_movement_points_max, get_unit_movement_points_max
export (Dictionary) var unit_tile_movement_costs # maps tile types to the movement cost for moving across that type of tile
var unit_can_move : bool = true setget set_unit_can_move, get_unit_can_move
		# position
var unit_tile_index : Vector2	 setget set_unit_tile_index, get_unit_tile_index # Unit does not directly change tile index, must be handled by tilemap. Stored in unit for serialization purposes
		# health
export (int) var unit_health_points = 4 setget set_unit_health_points, get_unit_health_points
export (int) var unit_health_points_max = 4 setget set_unit_health_points_max, get_unit_health_points_max
		# general
export var unit_class = "Archer"
export var unit_team = "blue"
export var unit_name = ""
export var unit_id = "" # used to uniquely identify unit for (de)serialization and scene changes. unix epoch of when unit is generated
		# attacking, weapons, and gear
var unit_can_attack : bool = true setget set_unit_can_attack, get_unit_can_attack
var unit_weapon_data : Dictionary # contains info on weapons this unit has

var unit_equipable_subtypes : Array # List of item types this unit can equip

var is_selected : bool = false # whether or not the unit is selected

var attack_animation_asset = preload("res://scenes/combat/AttackAnimation.tscn")	# attack animation on all affected tiles
var death_animation_asset = preload("res://scenes/combat/DeathAnimation.tscn")
var blood_particles_asset = preload("res://scenes/combat/UnitBloodParticles.tscn")

var last_bfs = Dictionary() # last pathing result from self.get_bfs. Used for checking movement. tile_indexes:cost
var last_attack_pattern = Dictionary() # last calculated attack pattern. Used for checking attacks. tile_indexes:attack_data
var last_damage_pattern = Dictionary() # last calculated damage pattern. Used for applying attacks. tile_indexes:attack_data

var unit_texture_path : String

var unit_death_audio_path : String
var unit_damaged_audio_path : String

var unit_death_animation_frame_paths : Array

var unit_is_boss : bool
var unit_move_after_attack : bool	# if unit can move again after attacking

var unit_damage_resistances : Dictionary

var unit_xp : int setget set_unit_xp, get_unit_xp
var unit_xp_max : int
var unit_level : int setget set_unit_level, get_unit_level
var unit_level_max : int
var unit_xp_reward : int # xp reward for killing the unit
var unit_level_up_rewards : Dictionary # maps xp levels to key:values that will override existing values

var unit_recruitment_cost : int
var unit_upkeep_cost : int

var unit_pending_bonus_xp : int # xp that's been awarded 

onready var root = get_tree().get_root().get_node("Root")	# reference to root game node
onready var relay = get_node("/root/SignalRelay")

func _ready():
	add_to_group("units")
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	
	# emitters
	self.connect("unit_health_changed", self.health_bar, "_on_unit_health_changed")	
	self.connect("unit_spawned", relay, "_on_unit_spawned")
	# self.connect("unit_clicked", relay, "_on_unit_clicked")
	self.connect("unit_killed", relay, "_on_unit_killed")
	self.connect("unit_mouse_entered", relay, "_on_unit_mouse_entered")
	self.connect("unit_mouse_exited", relay, "_on_unit_mouse_exited")
	self.connect("unit_boss_killed", relay, "_on_unit_boss_killed")
	self.connect("unit_level_changed", relay, "_on_unit_level_changed")
	self.connect("unit_xp_changed", relay, "_on_unit_xp_changed")
	self.connect("unit_leveled_up", relay, "_on_unit_leveled_up")
	self.connect("unit_item_broke", relay, "_on_unit_item_broke")
	
	# listeners
	relay.connect("unit_selected", self, "_on_unit_selected")
	relay.connect("unit_deselected", self, "_on_unit_deselected")
	relay.connect("unit_moved", self, "_on_unit_moved")
	relay.connect("unit_attacks_tile", self, "_on_unit_attacks_tile")
	relay.connect("unit_attacks_unit", self, "_on_unit_attacks_unit")
	relay.connect("unit_collides_unit", self, "_on_unit_collides_unit")
	
	relay.connect("team_start_turn", self, "_on_team_start_turn")
	relay.connect("team_end_turn", self, "_on_team_end_turn")
	relay.connect("unit_killed", self, "_on_unit_killed")
	relay.connect("unit_leveled_up", self, "_on_unit_leveled_up")
	relay.connect("unit_item_broke", self, "_on_unit_item_broke")
	
	relay.connect("tilemap_damage_preview", self, "_on_tilemap_damage_preview")
	
func init(unit_position : Vector2, unit_args: Dictionary, is_reinitializing = false):
	# Initialize unit with a position and given arguments. is_reinitializing is used for units leveling up and undoing state and thus overwriting data
	
	self.position = unit_position	# world position not tile index
	self.unit_tile_index = Vector2(unit_args["unit_tile_index"][0], unit_args["unit_tile_index"][1])
	# unit args
	self.unit_name = unit_args["unit_name"]
	self.unit_id = unit_args.get("unit_id", "Unit-"+str(OS.get_unix_time()))
	self.unit_team = unit_args["unit_team"]
	self.unit_movement_points = unit_args["unit_movement_points"]
	self.unit_movement_points_max = unit_args["unit_movement_points_max"]
	self.unit_tile_movement_costs = unit_args["unit_tile_movement_costs"]
	
	self.unit_health_points = unit_args["unit_health_points"]
	self.unit_health_points_max = unit_args["unit_health_points_max"]
	self.unit_class = unit_args["unit_class"]
	self.unit_weapon_data = unit_args["unit_weapon_data"]
	
	self.unit_equipable_subtypes = unit_args["unit_equipable_subtypes"]
	
	self.unit_damage_resistances = unit_args["unit_damage_resistances"]
	
	# set unit sprite
	self.unit_texture_path = unit_args["unit_texture_path"]
	self.unit_sprite.texture = load(self.unit_texture_path)
	
	# death animations
	self.unit_death_animation_frame_paths = unit_args["unit_death_animation_frame_paths"]
	
	# audio
	self.unit_death_audio_path = unit_args["unit_death_audio_path"]
	self.unit_damaged_audio_path = unit_args["unit_damaged_audio_path"]
	
	# costs
	self.unit_recruitment_cost = int(unit_args["unit_recruitment_cost"])
	self.unit_upkeep_cost = int(unit_args["unit_upkeep_cost"])
	
	# xp and levels
	self.unit_xp_max = int(unit_args["unit_xp_max"])
	self.unit_xp = int(unit_args["unit_xp"])
	self.unit_level_max = int(unit_args["unit_level_max"])
	self.unit_level = int(unit_args["unit_level"])
	self.unit_xp_reward = int(unit_args["unit_xp_reward"])
	self.unit_level_up_rewards = unit_args["unit_level_up_rewards"]
	
	# boss unit info
	self.unit_is_boss = unit_args["unit_is_boss"]
	$BossSkull.hide()
	if self.unit_is_boss:
		$BossSkull.show()
	
	# initialize health bar
	self.health_bar.init(unit_health_points,unit_health_points_max)
	self.health_bar.hide()
	
	# xp bar
	self.xp_bar.init(self)
	
	# change colors on UI stuff
	team_indicator.modulate = self.root.colors[self.unit_team]
	
	self.unit_can_move = unit_args.get("unit_can_move", true)
	self.unit_can_attack = unit_args.get("unit_can_attack", true)
	self.unit_move_after_attack = unit_args["unit_move_after_attack"]
	
	if !is_reinitializing:
		emit_signal("unit_spawned", self)
		
	# award pending bonus xp
	self.unit_pending_bonus_xp = 0
	var bonus_xp = int(unit_args["unit_pending_bonus_xp"])
	self.unit_xp += bonus_xp

func damage_unit(damage, attacking_unit = null):
	if damage.has("normal"):
		var resistance = self.unit_damage_resistances.get("normal", 0)
		var total_damage = damage["normal"] - resistance
		self.unit_health_points = clamp(self.unit_health_points - total_damage, 0, self.unit_health_points_max)
		self.floating_damage_text.init(total_damage)
	if self.unit_health_points <= 0:
		emit_signal("unit_killed", self, attacking_unit)
		if self.unit_is_boss:
			emit_signal("unit_boss_killed", self)

func play_attack_animation(direction):
	if direction in self.directions_to_unit_animations:
		self.directions_to_unit_animations[direction].play("Attacking")

func emit_levelup_particles():
	self.levelup_particles.emitting = false
	self.levelup_particles.emitting = true
	
func degrade_weapon_durability(item_id):
	if self.unit_weapon_data[item_id].has("item_durability"):
		self.unit_weapon_data[item_id]["item_durability"] -= 1
		if self.unit_weapon_data[item_id]["item_durability"] <= 0:
			emit_signal("unit_item_broke", self, item_id)

func _on_unit_item_broke(unit, item_id):
	if unit == self:
		self.unit_weapon_data.erase(item_id)

func _on_unit_selected(unit):
	is_selected = false
	self.health_bar.hide()
	if unit == self:
		is_selected = true
		self.health_bar.show()
		
func _on_unit_deselected(unit):
	is_selected = false
	self.health_bar.hide()

func _on_team_start_turn(team):
	if self.unit_team == team:
		self.unit_can_move = true
		self.unit_can_attack = true
		self.unit_movement_points = self.unit_movement_points_max

func _on_team_end_turn(team):
	if self.unit_team == team:
		self.unit_can_move = false
		self.unit_can_attack = false
		
func _on_unit_moved(unit, previous_tile_index, tile_index, movement_cost):
	if unit == self:
		self.set_unit_can_move(false)
		self.unit_tile_index = tile_index
		self.unit_movement_points -= movement_cost

func _on_unit_attacks_tile(attacking_unit, tile_index, attacking_unit_attack_pattern, attacking_unit_weapon_data):
	if self == attacking_unit:
		var attack_direction = self.last_attack_pattern[tile_index]["direction"]
		self.play_attack_animation(attack_direction)
		self.unit_can_attack = false
		self.unit_can_move = false
		if self.unit_move_after_attack and self.unit_movement_points > 0:
			self.unit_can_move = true
		
		self.degrade_weapon_durability(attacking_unit_weapon_data["item_id"])

func _on_unit_attacks_unit(attacking_unit, damage_pattern, attacked_unit, damage_tile_index):
	print("Unit, damage tile index: ", damage_tile_index)
	# get direction attacker is attacking from
	var attack_direction = damage_pattern[damage_tile_index]["direction"]
	
	if attacking_unit == self:
		print("Unit: attacking ", attacked_unit.unit_name)
	if attacked_unit == self:
		var damage = damage_pattern[damage_tile_index]["damage"]
		self.damage_unit(damage, attacking_unit)
		var blood_particles = self.blood_particles_asset.instance()
		self.add_child(blood_particles)
		blood_particles.emit(attack_direction)
		
		
func _on_unit_collides_unit(attacking_unit, colliding_unit, collision_count, collided_unit):
	pass
	if colliding_unit == self or collided_unit == self:
		var collision_damage = { "normal": collision_count}
		
		print("Unit: ", colliding_unit.unit_name, " collides with ", collided_unit.unit_name)
		self.damage_unit(collision_damage, attacking_unit)

func _on_mouse_entered():
	emit_signal("unit_mouse_entered", self)
	self.health_bar.show()
	return
	print("Mouse Entered")

func _on_mouse_exited():
	emit_signal("unit_mouse_exited", self)
	if not self.is_selected:
		self.health_bar.hide()
	return
	print("Mouse Exited")

func _on_unit_leveled_up(unit):
	if unit == self:
		self.emit_levelup_particles()
			
func _on_tilemap_damage_preview(damage_pattern):
	# given a damage pattern, show how much damage will be done
	self.health_bar.generate_health_bar(self.unit_health_points, self.unit_health_points_max)
	if !self.is_selected:
		self.health_bar.hide()
	
	if self.unit_tile_index in damage_pattern.keys():
		var resistance = self.unit_damage_resistances.get("normal", 0)
		var damage_preview = damage_pattern[self.unit_tile_index]["damage"]["normal"] - resistance
		self.health_bar.generate_health_bar(self.unit_health_points, self.unit_health_points_max, damage_preview)
		self.health_bar.show()
	
		
	
func _on_unit_killed(killed_unit, killer_unit):
	if killer_unit == self:
		self.unit_xp += killed_unit.unit_xp_reward
	
	if killed_unit ==  self:
		self.erase_global_data_entry()
	
func set_unit_movement_points(value):
	unit_movement_points = value
func get_unit_movement_points():
	return unit_movement_points
func set_unit_movement_points_max(value):
	unit_movement_points_max = value
func get_unit_movement_points_max():
	return unit_movement_points_max
func set_unit_tile_index(value):
	unit_tile_index = value
func get_unit_tile_index():
	return unit_tile_index
func set_unit_health_points(value):
	unit_health_points = value
	emit_signal("unit_health_changed", unit_health_points, unit_health_points_max)
func get_unit_health_points():
	return unit_health_points
func set_unit_health_points_max(value):
	unit_health_points_max = value
	emit_signal("unit_health_changed", unit_health_points, unit_health_points_max)
func get_unit_health_points_max():
	return unit_health_points_max

func set_unit_can_move(canMove : bool):
	unit_can_move = canMove
	if unit_can_move:
		move_indicator.modulate = self.get_team_color()
	else:
		move_indicator.modulate = self.root.colors["white"]
		
func get_unit_can_move():
	return unit_can_move
	
func set_unit_can_attack(canAttack : bool):
	unit_can_attack = canAttack
	if unit_can_attack:
		attack_indicator.modulate = self.get_team_color()
	else:
		attack_indicator.modulate = self.root.colors["white"]
		
func get_unit_can_attack():
	return unit_can_attack
	
func get_team_color():
	return self.root.colors[self.unit_team]
	
func set_unit_xp(xp):
	unit_xp = xp
	
	var has_leveled_up = false
	var unit_args : Dictionary # maintain a dict repr of the unit which will keep track of all level up stat changes
	
	# remove xp until all level ups are achieved
	while(unit_xp >= self.unit_xp_max):
		if self.unit_level < self.unit_level_max:
			unit_xp = unit_xp - self.unit_xp_max
			self.unit_level += 1
			has_leveled_up = true
			
			# Grab a dict representation of the leveling unit and make changes to it on each level up
			unit_args = self.get_unit_repr()
			if self.unit_level_up_rewards.has(str(self.unit_level)):
				var level_up_rewards = self.unit_level_up_rewards[str(self.unit_level)]
				for unit_property_name in level_up_rewards:
					unit_args[unit_property_name] = level_up_rewards[unit_property_name]
		else:
			unit_xp = self.unit_xp_max
			break
					
	# If a level up has happened apply all the changes and reinitialize unit
	if has_leveled_up:
		print("Unit: Leveling up. Reinitizalize")
		self.init(self.position, unit_args, true)
		emit_signal("unit_leveled_up", self)
	emit_signal("unit_xp_changed", self)
	
func get_unit_xp():
	return unit_xp

func set_unit_level(level):
	unit_level = int(min(level, self.unit_level_max))
	emit_signal("unit_level_changed", self)
func get_unit_level():
	return unit_level

###### Serialization and global data management #####

func update_global_data_entry():
	# updates the game data at the root
	self.root.game_data["unit_data"][self.unit_id] = self.get_unit_repr()
	
func erase_global_data_entry():
	# removes entry from global game data at root
	print("Unit: killed, data erased")
	self.root.game_data["unit_data"].erase(self.unit_id)
	self.root.game_data["main_data"]["party_unit_ids"].erase(self.unit_id)
	
	var current_event_id = self.root.game_data["main_data"]["current_event_id"]
	self.root.game_data["event_data"][current_event_id]["event_unit_ids"].erase(self.unit_id)

func get_unit_repr():
	# returns dictionary containing all data for this unit
	var unit_data = Dictionary();
	unit_data["unit_name"] = self.unit_name
	unit_data["unit_id"] = self.unit_id
	unit_data["unit_team"] = self.unit_team
	unit_data["unit_movement_points"] = self.unit_movement_points
	unit_data["unit_movement_points_max"] = self.unit_movement_points_max
	unit_data["unit_tile_movement_costs"] = self.unit_tile_movement_costs
	unit_data["unit_tile_index"] = self.unit_tile_index
	unit_data["unit_health_points"] = self.unit_health_points
	unit_data["unit_health_points_max"] = self.unit_health_points_max
	unit_data["unit_class"] = self.unit_class
	unit_data["unit_weapon_data"] = self.unit_weapon_data
	unit_data["unit_can_move"] = self.unit_can_move
	unit_data["unit_can_attack"] = self.unit_can_attack
	unit_data["unit_move_after_attack"] = self.unit_move_after_attack
	unit_data["unit_texture_path"] = self.unit_texture_path
	unit_data["unit_death_audio_path"] = self.unit_death_audio_path
	unit_data["unit_damaged_audio_path"] = self.unit_damaged_audio_path
	unit_data["unit_death_animation_frame_paths"] = self.unit_death_animation_frame_paths
	unit_data["unit_is_boss"] = self.unit_is_boss
	unit_data["unit_equipable_subtypes"] = self.unit_equipable_subtypes
	unit_data["unit_recruitment_cost"] = self.unit_recruitment_cost
	unit_data["unit_upkeep_cost"] = self.unit_upkeep_cost
	unit_data["unit_xp"] = self.unit_xp
	unit_data["unit_xp_max"] = self.unit_xp_max
	unit_data["unit_level"] = self.unit_level
	unit_data["unit_level_max"] = self.unit_level_max
	unit_data["unit_xp_reward"] = self.unit_xp_reward
	unit_data["unit_pending_bonus_xp"] = self.unit_pending_bonus_xp
	unit_data["unit_level_up_rewards"] = self.unit_level_up_rewards
	unit_data["unit_damage_resistances"] = self.unit_damage_resistances
	
	return unit_data;