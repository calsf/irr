# Enemy that moves to multiple points
extends Enemy
class_name MoveToPoints

export var is_cycle = false

onready var positions_par = $Positions

var next_pos = 1	# Index of next position, index 0 will always be the starting position so use index 1
var positions = []	# Array of positions to move to based on positions_par children

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get all starting global positions of nodes in Positions children as the points to move to
	for node in positions_par.get_children():
		positions.append(node.global_position)

# Move to points, movement handled in physics process by Enemy class
func _move(delta):
	global_position = global_position.move_toward(positions[next_pos], _move_speed * delta)
	if (global_position.distance_to(positions[next_pos]) <= 0.1):
		next_pos += 1
		
		# If next_pos is outside array, wrap back to beginning
		if (next_pos > positions.size() - 1):
			next_pos = 0
			# If not a cycle, reverse positions array to go back
			if (!is_cycle):
				positions.invert()
