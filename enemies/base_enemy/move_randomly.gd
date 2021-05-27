# Still enemy that moves around randomly once aggro'd
extends Enemy
class_name MoveRandomly

# How far from room origin bounds are
export var x_right : int
export var x_left : int
export var y_up : int
export var y_down : int

# Time in between finding new position to move to
export var _move_time_min = 3
export var _move_time_max = 9
export var _face_moving = false

onready var _move_timer = $MoveTimer
onready var _shadow_sprite = $Shadow

# Movement bounds
var x_right_bound = 0
var x_left_bound = 0
var y_up_bound = 0
var y_down_bound = 0

var _curr_target_pos = null
var _random = RandomNumberGenerator.new()

func _ready():
	# Starts in stationary position
	is_move_state = false

	# Start moving immediately once aggro'd
	connect("aggro_started", self, "enter_move_state")
	_move_timer.connect("timeout", self, "_get_new_pos")
	
	# Only load if need to face moving direction
	if _face_moving:
		Texture_Left = load(_left_path)
		Texture_Right = load(_right_path)
	
	# Set bounds based on rooms origin and get first position to move to
	var origin = get_parent().get_owner().global_position
	x_right_bound = origin.x + x_right
	x_left_bound = origin.x + x_left
	y_up_bound = origin.y + y_up
	y_down_bound = origin.y + y_down
	_get_new_pos()
	

func _physics_process(delta):
	if is_move_state and knockback == Vector2.ZERO:
			# Face moving direction if needed
			if _face_moving:
				if velocity.x < 0:
					_body_sprite.texture = Texture_Left
					if (_body_sprite.scale.x < 0):
						_body_sprite.scale.x *= -1
						_shadow_sprite.scale.x *= -1
				else:
					_body_sprite.texture = Texture_Right
					if (_body_sprite.scale.x > 0):
						_body_sprite.scale.x *= -1
						_shadow_sprite.scale.x *= -1
						
	# If within range of target pos, find a new position
	if is_move_state and global_position.distance_to(_curr_target_pos) < 20:
		_get_new_pos()

# Get new target position to move to
func _get_new_pos():
	_random.randomize()
	var x = _random.randi_range(x_left_bound, x_right_bound)
	var y = _random.randi_range(y_up_bound, y_down_bound)
	_curr_target_pos = Vector2(x, y)
	
	_random.randomize()
	var time = _random.randi_range(_move_time_min, _move_time_max)
	_move_timer.start(time)

# In move state, will always move towards target position
func _move(delta, other):
	velocity = (_curr_target_pos - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed
