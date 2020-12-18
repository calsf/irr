extends YSort

const STARTING_ID = 0 # Starting room id should be 0

var Portal = preload("res://levels/components/portal/Portal.tscn")

onready var enemies = $Enemies

# This rooms room id as assigned by map gen, init to -1
var room_id = -1

# Valid portals to next rooms
var has_up = false
var has_down = false
var has_left = false
var has_right = false

# Portal scenes
var up = null
var down = null
var left = null
var right = null

# Destination room scene each portal will teleport to
var next_up_room = null
var next_down_room = null
var next_left_room = null
var next_right_room = null

# Location of portals in this room
var up_loc
var down_loc
var left_loc 
var right_loc

# Condition for clearing all enemies in this room
var room_cleared = false

# Condition for solving any puzzles in this room
var room_solved = false

# If room is locked or not
var is_locked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	up_loc = $PortalLoc/Up.global_position
	down_loc = $PortalLoc/Down.global_position
	left_loc = $PortalLoc/Left.global_position
	right_loc = $PortalLoc/Right.global_position
	_create_portals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If no enemies, unlock room, else room should be locked
	if enemies.get_child_count() <= 0:
		room_cleared = true
	else:
		is_locked = true
		room_cleared = false
	
	# Unlock room portals once condition is met
	if is_locked and room_cleared:
		unlock_portals()

# Assigns all valid portal properties based on map gen
func assign_portals():
	if has_up:
		# Assign portal destination location and room id
		up.dest_portal = next_up_room.down
		up.dest_loc = next_up_room.down_loc
		up.dest_room = next_up_room
		
		# If this is room is the starting room, enable portals in this room
		# Portal's enable should enable it's destination portal
		if room_id == STARTING_ID:
			up.enable_portal()
	if has_down:
		# Assign portal destination location and room id
		down.dest_portal = next_down_room.up
		down.dest_loc = next_down_room.up_loc
		down.dest_room = next_down_room
		
		# If this is room is the starting room, enable portals in this room
		# Portal's enable should enable it's destination portal
		if room_id == STARTING_ID:
			down.enable_portal()
	if has_left:
		# Assign portal destination location and room id
		left.dest_portal = next_left_room.right
		left.dest_loc = next_left_room.right_loc
		left.dest_room = next_left_room
		
		# If this is room is the starting room, enable portals in this room
		# Portal's enable should enable it's destination portal
		if room_id == STARTING_ID:
			left.enable_portal()
	if has_right:
		# Assign portal destination location and room id
		right.dest_portal = next_right_room.left
		right.dest_loc = next_right_room.left_loc
		right.dest_room = next_right_room
		
		# If this is room is the starting room, enable portals in this room
		# Portal's enable should enable it's destination portal
		if room_id == STARTING_ID:
			right.enable_portal()

# Creates portals and disables them immediately
func _create_portals():
	up = Portal.instance()
	add_child(up)
	up.global_position = up_loc
	up.disable_portal()
	
	down = Portal.instance()
	add_child(down)
	down.global_position = down_loc
	down.disable_portal()
	
	left = Portal.instance()
	add_child(left)
	left.global_position = left_loc
	left.disable_portal()
	
	right = Portal.instance()
	add_child(right)
	right.global_position = right_loc
	right.disable_portal()

# Enables all valid portals in this room
func unlock_portals():
	is_locked = false
	if has_up:
		up.enable_portal()
	if has_down:
		down.enable_portal()
	if has_left:
		left.enable_portal()
	if has_right:
		right.enable_portal()

# Disables all portals in this room, plays their lock animation
func lock_portals():
	up.disable_with_anim()
	down.disable_with_anim()
	left.disable_with_anim()
	right.disable_with_anim()
	is_locked = true
