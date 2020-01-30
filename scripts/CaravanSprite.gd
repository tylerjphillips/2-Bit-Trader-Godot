extends Sprite

onready var root = get_tree().get_root().get_node("Root")
onready var caravan_travel_tween = $CaravanTravelTween

var caravan_traveling := false
var to_location_id = ""

signal caravan_destination_reached # (to_location_id)
signal caravan_started_traveling # (to_location_id)

func _ready():
	pass
	
func initialize_caravan_position():
	# place the caravan at the current location
	var overworld_data = root.game_data["overworld_data"]
	var current_location_id = root.game_data["main_data"]["current_location_id"]

	var current_pos = overworld_data[current_location_id]["location_coords"]
	current_pos = Vector2(current_pos[0],current_pos[1])		# array->vector2
	
	self.position = current_pos

func _on_overworld_location_button_up(to_location_id):
	# Attempting to select a location to travel to
	if !caravan_traveling:
		var current_location_id = root.game_data["main_data"]["current_location_id"]
		var current_location_neighbor_ids : Array = root.game_data["overworld_data"][current_location_id]["location_neighbor_ids"]
		if current_location_neighbor_ids.find(to_location_id) != -1:
			move_caravan_to_location(to_location_id)
			self.caravan_traveling = true
			self.to_location_id = to_location_id
			emit_signal("caravan_started_traveling", self.to_location_id)
		else:
			print("CaravanSprite: Location not adjacent")
	else:
		print("CaravanSprite: Already traveling")

func move_caravan_to_location(destination_location_id):
	# Smoothly moves caravan to the next event in the overworld
	var destination_pos = root.game_data["overworld_data"][destination_location_id]["location_coords"]
	destination_pos = Vector2(destination_pos[0], destination_pos[1])
	caravan_travel_tween.interpolate_property(self, "position", self.position, destination_pos, 2 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	caravan_travel_tween.start()

func _on_CaravanTravelTween_completed(object, key):
	self.caravan_traveling = false
	emit_signal("caravan_destination_reached", self.to_location_id)
