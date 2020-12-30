# Generates a map layout using pre-made rooms
# Creates one main path of rooms, each room in main path may spawn dead end rooms
# Whenever new room is added, checks the new room position relative to the last room
# Using the position, assign navigation properties to the portal in the last room
extends YSort

const UP = Vector2(0, -480)
const DOWN = Vector2(0, 480)
const LEFT = Vector2(-640, 0)
const RIGHT = Vector2(640, 0)

var closed_loc = []	# Closed locations that already have a room
var open_loc = []	# Open locations to choose from to add next room
var curr_longest_path = 0	# Number of rooms currently in longest path
var next_room_id = 0 # id of next room, should be incremented after

var created_rooms = [] # All created rooms
var last_room = null	# Room that was previously added

# Target number of rooms for longest path
export var target_longest_path : int

# Path of starting room scene
export var start_room_path : String

# Path of end room scene
export var end_room_path : String

# Paths of all intermediate room scenes to be randomly picked from
export var normal_rooms_path : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	# Init starting room, should have id of 0
	last_room = _add_new_room(Vector2.ZERO, start_room_path)
	curr_longest_path += 1	# Longest path includes start room
	
	# Add 4 new open locations from the starting room's origin
	open_loc = _add_open_loc(Vector2.ZERO, open_loc)
	
	# Init last open locations to be the 4 locations from origin
	var last_open_loc = _add_open_loc(Vector2.ZERO, [])
	
	# Populate map until target longest path reached
	while curr_longest_path < target_longest_path and not open_loc.empty():
		var loc = open_loc[0]
		
		# If more than 1 loc in open_loc, pick a random open location to use
		if open_loc.size() > 1:
			randomize()
			loc = open_loc[randi() % open_loc.size()]
		
		# If this is last room to add before hitting target path length, add end room
		# Else add a new normal room to scene at loc, picks randomly from normal_rooms_path
		var next_room = null
		if curr_longest_path == target_longest_path - 1:
			next_room = _add_new_room(loc, end_room_path)
		else:
			next_room = _add_new_room(loc, normal_rooms_path[randi() % normal_rooms_path.size()])
		
		curr_longest_path += 1	# Increment path since this new room is part of the main path
		
		# Init last and next rooms next portals based on loc of next room
		call_deferred("_init_room_portals", last_room, next_room, loc)
		
		# Remove the newly added room location from open_loc
		open_loc.erase(loc)
		
		# Remove the open locs from last origin from open_loc so that we keep building a main path
		# This way we ensure one longest main path for player to follow/minimal backtracking
		# _remove_open_loc will handle adding any extra dead end rooms
		if last_open_loc.has(loc):		# First remove loc if it exists to avoid dupe remove
			last_open_loc.erase(loc)
		open_loc = _remove_open_loc(last_open_loc, open_loc)
		
		# Set last room to this next room AFTER adding dead ends in _removing_open_loc
		last_room = next_room
		
		# Reset to be 4 locations from this new origin loc (this new room is new origin) 
		last_open_loc = _add_open_loc(loc, [])
		
		# Add the 4 new open locations from the new room's origin loc
		open_loc = _add_open_loc(loc, open_loc)
	
	# Have room finalize portal properties for all created rooms
	for room in created_rooms:
		room.call_deferred("assign_portals")

# Adds locations left, right, up, down from origin vector to arr only if they are open
# Returns modified arr
func _add_open_loc(origin, arr):
	if not closed_loc.has(origin + UP):
		arr.append(origin + UP)
	if not closed_loc.has(origin + DOWN):
		arr.append(origin + DOWN)
	if not closed_loc.has(origin + LEFT):
		arr.append(origin + LEFT)
	if not closed_loc.has(origin + RIGHT):
		arr.append(origin + RIGHT)
	
	return arr

# Removes all last_open from curr_open
# ALSO: Picks random # of rooms from 0 to last_open size
	# Will add that many new dead end rooms using random locations from last_open
	# THESE ROOMS ARE NOT PART OF LONGEST PATH AND SHOULD NOT INCREMENT LONGEST_PATH COUNT
# last_open - should be an arr of locations left, right, up, down from last origin vector
# curr_open - ALL open locations from all origins
# Returns the modified curr_open
func _remove_open_loc(last_open, curr_open):
	var num_to_remove = last_open.size()	# Remove all open loc from last origin
	
	# Get random # between 1 - all of items in last_open
	# Will be the # of rooms to add, but these rooms are not part of main path
	# Will not be added to curr_open as these new rooms are intended to be dead ends
	randomize()
	var num_to_add = randi() % last_open.size()
	
	# Remove num_to_remove items from curr_open
	while num_to_remove > 0:
		var loc = last_open[0]
		
		# If more than 1 item in last_open, pick a random item to remove
		if last_open.size() > 1:
			randomize()
			loc = last_open[randi() % (last_open.size() - 1)]
			
			# If we need to add rooms, add room at this random loc
			if num_to_add > 0:
				var next_room = _add_new_room(loc, normal_rooms_path[randi() % normal_rooms_path.size()])
				
				# Init last and next rooms next portals based on loc of new room
				call_deferred("_init_room_portals", last_room, next_room, loc)
		
		# We remove from last_open to make sure we don't remove dupes
		last_open.erase(loc)
		
		# Remove from curr_open
		curr_open.erase(loc)
		num_to_remove -= 1
	
	return curr_open

# Add new room to scene, returns the new room scene
func _add_new_room(loc, room_path):
	var room = load(room_path)
	var new_room = room.instance()
	get_tree().current_scene.call_deferred("add_child", new_room)
	new_room.global_position = loc
	
	# Close off loc so cannot add another room to this loc
	closed_loc.append(loc)
	
	# Add new room to created rooms
	created_rooms.append(new_room)
	
	# Assign id to new room and return new room
	new_room.room_id = next_room_id
	next_room_id += 1	# Increment id for next room
	return new_room

# Inits valid portals and store their target destination location and room ids
func _init_room_portals(last_room, next_room, loc):
	# Last rooms position + some direction should be equal to the loc of new room
	# Assign portal based on the direction
	if last_room.global_position + UP == loc:
		# Set valid portals
		last_room.has_up = true
		next_room.has_down = true
		
		# Assign next rooms for portals
		last_room.next_up_room = next_room
		next_room.next_down_room = last_room
	elif last_room.global_position + DOWN == loc:
		# Set valid portals
		last_room.has_down = true
		next_room.has_up = true
		
		# Assign next rooms for portals
		last_room.next_down_room = next_room
		next_room.next_up_room = last_room
	elif last_room.global_position + LEFT == loc:
		# Set valid portals
		last_room.has_left = true
		next_room.has_right = true
		
		# Assign next rooms for portals
		last_room.next_left_room = next_room
		next_room.next_right_room = last_room
	elif last_room.global_position + RIGHT == loc:
		# Set valid portals
		last_room.has_right = true
		next_room.has_left = true
		
		# Assign next rooms for portals
		last_room.next_right_room = next_room
		next_room.next_left_room = last_room
		
