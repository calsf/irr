extends YSort

var Portal = preload("res://Portal.tscn")

# This rooms room id as assigned by map gen
var room_id = 0

# Valid portals to next rooms
var has_up = false
var has_down = false
var has_left = false
var has_right = false

# Location of portals in this room
var up_loc
var down_loc
var left_loc 
var right_loc

# Destination room each portal will teleport to
var next_up_room
var next_down_room
var next_left_room
var next_right_room

# Condition for clearing all enemies in this room
var room_cleared = false

# Condition for solving any puzzles in this room
var room_solved = false

# Called when the node enters the scene tree for the first time.
func _ready():
	up_loc = $PortalLoc/Up.global_position
	down_loc = $PortalLoc/Down.global_position
	left_loc = $PortalLoc/Left.global_position
	right_loc = $PortalLoc/Right.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not room_cleared:
		room_cleared = true
		_activate_portals()

# Spawns all valid portals based on map gen
func _activate_portals():
	if has_up:
		var up = Portal.instance()
		add_child(up)
		up.global_position = up_loc
		
		# Assign portal destination location and room id
		up.dest_loc = next_up_room.down_loc
		up.dest_room_id = next_up_room.room_id
	if has_down:
		var down = Portal.instance()
		add_child(down)
		down.global_position = down_loc
		
		# Assign portal destination location and room id
		down.dest_loc = next_down_room.up_loc
		down.dest_room_id = next_down_room.room_id
	if has_left:
		var left = Portal.instance()
		add_child(left)
		left.global_position = left_loc
		
		# Assign portal destination location and room id
		left.dest_loc = next_left_room.right_loc
		left.dest_room_id = next_left_room.room_id
	if has_right:
		var right = Portal.instance()
		add_child(right)
		right.global_position = right_loc
		
		# Assign portal destination location and room id
		right.dest_loc = next_right_room.left_loc
		right.dest_room_id = next_right_room.room_id
