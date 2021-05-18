# LEVEL 2 BOSS BEHAVIOR
# PHASE ONE:
# Move from position to position, randomly picks new position after some time
# Repeatedly normal attack, shooting projectiles in fixed directions from arms
# Getting hit shoots projectile at player from SpawnPos
# PHASE TWO:
# Same as phase 1 but arms will not shoot big projectiles that split
# Will still move from position to position and shoot at player if gets hit
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 500

# Time in between finding new position to move to
const MOVE_TIME_MIN = 3
const MOVE_TIME_MAX = 9

const NORM_ATTACK_TIME = 1
const SPLIT_ATTACK_TIME = 2.5

export var proj_path_norm : String
export var proj_path_split : String
onready var NormProj = load(proj_path_norm)
onready var SplitProj = load(proj_path_split)

# Movement bounds
const X_RIGHT_BOUND = 244
const X_LEFT_BOUND = -244
const Y_UP_BOUND = -178
const Y_DOWN_BOUND = 188

onready var _attack_timer = $Body/Attack/AttackTimer
onready var _move_timer = $MoveTimer
onready var _arm_spawns = get_node("Body/Attack/ArmSpawns").get_children()
onready var _eye_spawn = $Body/Attack/SpawnPos
onready var _attack_anim = $Body/Attack/AttackAnimation

var _curr_target_pos = Vector2.ZERO
var _random = RandomNumberGenerator.new()
var _possible_dir = [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, -1),
	Vector2(0, 1),
	Vector2(1, 1),
	Vector2(-1, -1),
	Vector2(1, -1),
	Vector2(-1, 1)
]

func _ready():
	enter_idle_state()
	
	_move_timer.connect("timeout", self, "_get_new_pos")
	_attack_timer.connect("timeout", self, "_start_attack")

func _physics_process(delta):
	# If within range of target pos, find a new position
	if global_position.distance_to(_curr_target_pos) < 20:
		_get_new_pos()

# Get new target position to move to
func _get_new_pos():
	_random.randomize()
	var x = _random.randi_range(X_LEFT_BOUND, X_RIGHT_BOUND)
	var y = _random.randi_range(Y_UP_BOUND, Y_DOWN_BOUND)
	_curr_target_pos = Vector2(x, y)
	
	_random.randomize()
	var time = _random.randi_range(MOVE_TIME_MIN, MOVE_TIME_MAX)
	_move_timer.start(time)

# Starts attack animation
func _start_attack():
	if (_curr_hp <= PHASE_TWO_THRESHOLD):
		_attack_anim.play("split_attack")
		_attack_timer.start(SPLIT_ATTACK_TIME)
	else:
		_attack_anim.play("normal_attack")
		_attack_timer.start(NORM_ATTACK_TIME)
	
	
# Shoot projectiles from arm positions, should be called during animation
# Shoot normal or split projectile depending on phase
func _attack():
	for pos in _arm_spawns:
		randomize()
		var selected_dir = _possible_dir[randi() % _possible_dir.size()]
		var obj = null
		
		if (_curr_hp <= PHASE_TWO_THRESHOLD):
			obj = SplitProj.instance()
		else:
			obj = NormProj.instance()
			
		get_tree().get_root().add_child(obj)
		obj.global_position = pos.global_position
		obj.dir = selected_dir.normalized()

# Overriding enter move state to start attack timer
func enter_move_state():
	is_move_state = true
	_anim.play("move")
	_attack_timer.start(NORM_ATTACK_TIME)

# Overriding update_health to shoot projectile back at player
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
		var obj = NormProj.instance()
		get_tree().get_root().call_deferred("add_child", obj)
		obj.global_position = _eye_spawn.global_position
		obj.dir = (player_obj.global_position - _eye_spawn.global_position).normalized()

# In move state, will always move towards target position
func _move(delta, other):
	velocity = (_curr_target_pos - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed
	
	
