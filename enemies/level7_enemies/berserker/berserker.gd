# Special behavior for enemy
# Moves randomly, also attacks faster as health gets lower
extends Enemy
class_name Berserker

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

var base_atk_rate = 0

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
	
	# Set base attack rate
	base_atk_rate = _attack_sprite.atk_rate

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

# Override update_health to also update attack rate based on remaining health
func update_health(change):
	_curr_hp += change
	
	# If change was negative, then enemy was damaged
	if change < 0:
		_damaged_flash()
	
	# Update health fill
	_health_fill.rect_size.x += change / _health_ratio
	
	# Reset health display timer, shows health display for 3 secs after health update
	_health_timer.start(DISPLAY_TIME)
	_health_display.visible = true
	
	# If health reaches 0 or below, enemy is dead
	if _curr_hp <= 0:
		# Instance death effect before removing enemy
		var death = load(_death_path).instance()
		get_tree().current_scene.add_child(death)
		death.global_position = global_position
		
		queue_free()
	elif change < 0:
		update_atk_rate()

func update_atk_rate():
	# Limit to lowest health possible that can increase atk rate
	# Allows for faster increase from earlier health loss
	if _curr_hp < (_enemy_props.max_hp / 5):
		return
	
	var health_multiplier = (float(_enemy_props.max_hp) / float(_curr_hp)) * 3
	_attack_sprite.atk_rate = float(base_atk_rate) / health_multiplier
