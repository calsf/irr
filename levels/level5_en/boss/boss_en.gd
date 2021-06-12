# LEVEL 5 BOSS BEHAVIOR
# PHASE ONE:
# Remains stationary, continuously spawn temporary projectiles at player position
# Temporary projectile spawns will predict ahead of player
# Will periodically teleport to player and absorb all active projectiles to self
# PHASE TWO:
# Start moving randomly, either to a random position, or towards player
# Will periodically shoot split projectiles in fixed directions
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 400

# Movement bounds
const X_RIGHT_BOUND = 265
const X_LEFT_BOUND = -265
const Y_UP_BOUND = -184
const Y_DOWN_BOUND = 192

# Attack rates
const STILL_ATK_RATE = .4
const ABSORB_RATE = 15

# Offset position of still projectile spawn
const OFFSET = Vector2(0, -14)

# Dist to spawn projectile ahead of player
const AHEAD = 56

# Base speed of projectiles to be absorbed
const ABSORB_PROJ_SPEED = 100

export var proj_path_still : String
export var proj_path_split : String
onready var StillProj = load(proj_path_still)
onready var SplitProj = load(proj_path_split)

onready var _spawn_pos = $Body/Attack/SpawnPos
onready var _atk_timer = $Body/Attack/AttackTimer
onready var _atk_timer_absorb = $AttackTimerAbsorb

var _active_projectiles = []
var _is_absorbing = false

func _ready():
	enter_idle_state()
	_atk_timer.connect("timeout", self, "_still_attack")
	_atk_timer_absorb.connect("timeout", self, "_disappear")

func _physics_process(delta):
	# While absorbing
	if _is_absorbing:
		# Check if all projectiles have been 'absorbed'
		if _active_projectiles.size() == 0:
			_finish_absorb()
		
		# For each active projectile, gradually increase speed
		# Also check if projectile is close to spawn position, if so, destroy projectile
		for proj in _active_projectiles:
			proj.dir = proj.dir * 1.02
			if proj.global_position.distance_to(_spawn_pos.global_position) < 20:
				_remove_projectile(proj)
				proj.queue_free()

# Enter phase depending on health and start attacking
func _enter_phase():
	if _curr_hp <= PHASE_TWO_THRESHOLD:	# Enter phase two
		pass
	else:	# Enter phase one
		_atk_timer.start(STILL_ATK_RATE)
		_atk_timer_absorb.start(ABSORB_RATE)
		_anim.play("phase_one")

# Spawn still/temp projectile at player position, is predictive
func _still_attack():
	# Stop attacking if is absorbing
	if _is_absorbing:
		return
		
	var target_pos = player_obj.global_position
	
	# Adjust appearance to 'predict' and appear ahead of player
	if player_obj.input_vector.x > 0:
		target_pos.x += AHEAD
	elif player_obj.input_vector.x < 0:
		target_pos.x -= AHEAD
	
	if player_obj.input_vector.y > 0:
		target_pos.y += AHEAD
	elif player_obj.input_vector.y < 0:
		target_pos.y -= AHEAD
	
	# Confine target pos within bounds
	if target_pos.x > X_RIGHT_BOUND:
		target_pos.x = X_RIGHT_BOUND
	elif target_pos.x < X_LEFT_BOUND:
		target_pos.x = X_LEFT_BOUND
	if target_pos.y > Y_DOWN_BOUND:
		target_pos.y = Y_DOWN_BOUND
	elif target_pos.y < Y_UP_BOUND:
		target_pos.y = Y_UP_BOUND
	
	# Spawn projectile
	var obj = StillProj.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = target_pos + OFFSET
	obj.dir = Vector2.ZERO
	
	# Set as active projectiles to be absorbed
	obj.connect("destroyed", self, "_remove_projectile", [obj])
	_active_projectiles.append(obj)
	
	# Repeat attack as long as above phase two threshold
	# If below, force absorb attack to transition
	if _curr_hp <= PHASE_TWO_THRESHOLD:
		_atk_timer_absorb.stop()
		_disappear()
	else:
		_atk_timer.start(STILL_ATK_RATE)

# Play disappear animation, should trigger reappear at end
func _disappear():
	_anim.play("disappear")

# Teleport to player position, play reappear animation, should call absorb attack
func _reappear():
	# Set position equal to player's position, clamping for position boundaries
	global_position.x = clamp(player_obj.global_position.x, X_LEFT_BOUND, X_RIGHT_BOUND)
	global_position.y = clamp(player_obj.global_position.y, Y_UP_BOUND, Y_DOWN_BOUND)
	
	_anim.play("reappear")
	
# Should be called after reappear animation to absorb all active projectiles
func _absorb_attack():
	_is_absorbing = true
	for proj in _active_projectiles:
		proj.dir = (_spawn_pos.global_position - proj.global_position).normalized()
		proj.set_speed(ABSORB_PROJ_SPEED)

# Finish absorb attack, should re-enter phase afterwards
func _finish_absorb():
	_is_absorbing = false
	_anim.play("finish_absorb")

# Remove projectile from array of active projectiles once it gets destroyed
func _remove_projectile(obj):
	_active_projectiles.erase(obj)


