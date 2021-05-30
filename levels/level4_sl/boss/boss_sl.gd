# LEVEL 4 BOSS BEHAVIOR
# PHASE ONE:
# Continuously spawn temporary projectiles at player position, will predict ahead of player
# PHASE TWO:
# Same as phase one but will also start shooting projectiles at player nonstop
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 750

# Bounds for still projectile to spawn
const X_RIGHT_BOUND = 264
const X_LEFT_BOUND = -264
const Y_UP_BOUND = -200
const Y_DOWN_BOUND = 174

# Offset position of projectile spawn
const OFFSET = Vector2(0, -14)

export var proj_path_norm : String
export var proj_path_still : String
onready var NormProj = load(proj_path_norm)
onready var StillProj = load(proj_path_still)

# Distance to predict ahead of player
export var x_ahead : int
export var y_ahead : int

export var norm_attack_rate : float
export var alt_attack_rate : float

onready var _spawn_pos = $Body/Attack/SpawnPos
onready var _atk_timer = $Body/Attack/AttackTimer
onready var _atk_anim = $Body/Attack/AttackAnimation
onready var _atk_timer_alt = $AttackTimerAlt

var phase_two_active = false

func _ready():
	enter_idle_state()
	_atk_timer.connect("timeout", self, "_norm_attack")
	_atk_timer_alt.connect("timeout", self, "_phase_two_attack")

func _physics_process(delta):
	# Start phase two attack once hp threshold is reached
	# _start_phase_two called in animation to start attacking
	if not phase_two_active and _curr_hp <= PHASE_TWO_THRESHOLD:
		_anim.play("phase_two_activate")
		phase_two_active = true

# Spawn still/temp projectile at player position, is predictive
func _norm_attack():
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
	
	_atk_timer.start(norm_attack_rate)

# Starts phase two
func _start_phase_two():
	_anim.play("move_alt")
	_phase_two_attack()

# Repeatedly shoot projectile at player
func _phase_two_attack():
	var obj = NormProj.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = _spawn_pos.global_position
	obj.dir = (player_obj.global_position - _spawn_pos.global_position).normalized()
	_atk_timer_alt.start(alt_attack_rate)

# Override enter move state to also start attacking
func enter_move_state():
	_atk_timer.start(norm_attack_rate)
	is_move_state = true
	_anim.play("move")

# Override apply knockback to do nothing - this boss cannot be knocked back
func apply_knockback(knockback_vector, knockback_strength):
	pass
