extends Node2D

var region_id = ""
var region_name = ""
var region_point_list = []	# array of vector2s defining the border of the region

onready var region_border = $OverworldRegionBorder		# linelist making up the border
onready var region_polygon = $OverworldRegionPolygon	# polygon defining the "body"

func _ready():
	pass

func init(region_args):
	
	self.region_name = region_args["region_name"]
	self.region_id = region_args.get("region_id", str(OS.get_unix_time()))
	
	var temp_point_list = region_args["region_polygon_point_list"]	# needs to be converted to vector2s
	
	# iterate through temp point list and convert it to vector2s
	for p in temp_point_list:
		var point = Vector2(p[0],p[1])
		region_border.add_point(point)
		self.region_point_list.append(point)
	region_border.add_point(region_point_list[0])	# add first point to the end of border's line list to complete loop
	region_polygon.set_polygon(PoolVector2Array(self.region_point_list))	# define region body polygon