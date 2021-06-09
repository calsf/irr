# LEVEL 5 BOSS BEHAVIOR
# PHASE ONE:
# Stationary and cannot be knocked back, Continuously spawn temporary projectiles 
# at player position, will predict ahead of player
# Taking damage will also shoot projectile at player
# PHASE TWO:
# Start moving randomly, either to a random position, or towards player
# Will periodically shoot split projectiles in fixed directions
# No longer shoots projectile at player when taking damage and can be knocked back
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 400

# Movement bounds
const X_RIGHT_BOUND = 265
const X_LEFT_BOUND = -265
const Y_UP_BOUND = -184
const Y_DOWN_BOUND = 192

# Attack rates
const STILL_ATK_RATE = .6

# Offset position of still projectile spawn
const OFFSET = Vector2(0, -14)

# Dist to spawn projectile ahead of player
const AHEAD = 56

export var proj_path_norm : String
export var proj_path_still : String
export var proj_path_split : String
onready var NormProj = load(proj_path_norm)
onready var StillProj = load(proj_path_still)
onready var SplitProj = load(proj_path_split)

onready var _spawn_pos = $Body/Attack/SpawnPos
onready var _atk_timer = $Body/Attack/AttackTimer

func _ready():
	enter_idle_state()
	_atk_timer.connect("timeout", self, "_still_attack")

func _physics_process(delta):
	pass

# Enter phase one and start attacking
func _enter_phase_one():
	_atk_timer.start(STILL_ATK_RATE)
	_anim.play("phase_one")

# Spawn still/temp projectile at player position, is predictive
func _still_attack():
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
	
	_atk_timer.start(STILL_ATK_RATE)


