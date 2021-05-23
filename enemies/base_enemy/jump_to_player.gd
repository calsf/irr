# Still enemy that will periodically "jump" to the player
# Will jump ahead x/y units of the player as specified by x_ahead and y_ahead
# Enemy should have a disappear and a reappear animation
extends Enemy
class_name JumpToPlayer

# Min and max delay time for next jump
export var jump_time_min : float
export var jump_time_max : float

# Distance to predict ahead of player
export var x_ahead : int
export var y_ahead : int

# How far from room origin bounds are
export var x_left : int
export var x_right : int
export var y_down : int
export var y_up : int

onready var _jump_timer = $Body/Attack/AttackTimer

# Movement bounds
var x_right_bound = 0
var x_left_bound = 0
var y_up_bound = 0
var y_down_bound = 0

var _random = RandomNumberGenerator.new()

func _ready():
	# Start and remain in idle until aggro
	enter_idle_state()
	
	# Enter activate state/play activate anim upon aggro
	# Activate anim should enter_move_state() once finished
	connect("aggro_started", self, "_start_jump")
	_jump_timer.connect("timeout", self, "_disappear")
	_jump_timer.one_shot = true # DO NOT RESTART TIMER AFTER IT REACHES 0
	
	# Set bounds based on rooms origin
	var origin = get_parent().get_owner().global_position
	x_right_bound = origin.x + x_right
	x_left_bound = origin.x + x_left
	y_up_bound = origin.y + y_up
	y_down_bound = origin.y + y_down

# Jump after some delay
func _start_jump():
	_random.randomize()
	var time = _random.randf_range(jump_time_min, jump_time_max)
	_jump_timer.start(time)

# Play disappear animation, animation should handle time to stay hidden
func _disappear():
	_anim.play("disappear")

# Should be called at end of disappear animation to set position and reappear
func _reappear():
	var target_pos = player_obj.global_position
	
	# Adjust appearance to 'predict' and appear ahead of player
	if player_obj.input_vector.x > 0:
		target_pos.x += x_ahead
	elif player_obj.input_vector.x < 0:
		target_pos.x -= x_ahead
	
	if player_obj.input_vector.y > 0:
		target_pos.y += y_ahead
	elif player_obj.input_vector.y < 0:
		target_pos.y -= y_ahead
	
	# Confine target pos within bounds
	if target_pos.x > x_right_bound:
		target_pos.x = x_right_bound
	elif target_pos.x < x_left_bound:
		target_pos.x = x_left_bound
	if target_pos.y > y_down_bound:
		target_pos.y = y_down_bound
	elif target_pos.y < y_up_bound:
		target_pos.y = y_up_bound
	
	# "Jump" to the target position and reappear
	global_position = target_pos
	_anim.play("reappear")

# Should be called at end of reappear animation to jump again
func _fin_reappear():
	_anim.play("idle")
	_start_jump()
