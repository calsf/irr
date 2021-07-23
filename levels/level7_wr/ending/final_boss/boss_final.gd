extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 1750

# Movement bounds
const X_RIGHT_BOUND = 260
const X_LEFT_BOUND = -260
const Y_UP_BOUND = -176
const Y_DOWN_BOUND = 192

# Offset position of still projectile spawn
const OFFSET = Vector2(0, -14)

# Dist to spawn projectile ahead of player
const AHEAD = 56

# Number of consecutive jumps
const LANDING_REPEAT = 3

# Number of temp projectiles to spawn at once
const NUM_TEMP_PROJ = 20

# Speed of a temp projectile
const TEMP_PROJ_SPEED = 250

const CLONE_POS = [
	Vector2(160, -112),
	Vector2(-160, -112),
	Vector2(160, 112),
	Vector2(-160, 112)
]

export var proj_path_split : String
export var proj_path_norm : String
export var proj_path_temp : String
onready var SplitProj = load(proj_path_split)
onready var NormProj = load(proj_path_norm)
onready var TempProj = load(proj_path_temp)

export var clone_path : String
onready var Clone = load(clone_path)

onready var _spawn_pos = $Body/Attack/SpawnPos

var _active_projectiles = []
var _active_clones = []
var _phase_two_active = false
var _random = RandomNumberGenerator.new()
var _landing_count = 0
var _dirs = [
	Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1),
		Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1),
		Vector2(.5, sqrt(3)/2), Vector2(-.5, sqrt(3)/2), Vector2(.5, -sqrt(3)/2), Vector2(-.5, -sqrt(3)/2),
		Vector2(sqrt(3)/2, .5), Vector2(-sqrt(3)/2, .5), Vector2(sqrt(3)/2, -.5), Vector2(-sqrt(3)/2, -.5),
		Vector2( (1 + sqrt(3)) / (2*sqrt(2)), (sqrt(3) - 1) / (2*sqrt(2)) ),
		Vector2( -(1 + sqrt(3)) / (2*sqrt(2)), (sqrt(3) - 1) / (2*sqrt(2)) ),
		Vector2( (1 + sqrt(3)) / (2*sqrt(2)), -(sqrt(3) - 1) / (2*sqrt(2)) ),
		Vector2( -(1 + sqrt(3)) / (2*sqrt(2)), -(sqrt(3) - 1) / (2*sqrt(2)) ),
		
		Vector2( (sqrt(3) - 1) / (2*sqrt(2)), (1 + sqrt(3)) / (2*sqrt(2)) ),
		Vector2( -(sqrt(3) - 1) / (2*sqrt(2)), (1 + sqrt(3)) / (2*sqrt(2)) ),
		Vector2( (sqrt(3) - 1) / (2*sqrt(2)), -(1 + sqrt(3)) / (2*sqrt(2)) ),
		Vector2( -(sqrt(3) - 1) / (2*sqrt(2)), -(1 + sqrt(3)) / (2*sqrt(2)) ),
	]

# Play disappear animation, animation should handle time to stay hidden
func _disappear():
	_anim.play("disappear")

# Should be called at end of disappear animation to set position and reappear
func _reappear():
	var target_pos = player_obj.global_position
	
	# Land in middle if finished landing attacks
	# Else land predictively on/ahead of the player
	if _landing_count >= LANDING_REPEAT or \
		(not _phase_two_active and _curr_hp <= PHASE_TWO_THRESHOLD):
			target_pos = Vector2.ZERO
	else:
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
	
	# "Jump" to the target position and reappear
	global_position = target_pos
	_anim.play("reappear")

# Start landing attack animation
func _start_attack_landing():
	if not _phase_two_active and _curr_hp <= PHASE_TWO_THRESHOLD:
		_activate_phase_two()
		return
		
	# Perform landing attack based on landing count
	if _landing_count < LANDING_REPEAT:
		# Perform attack landing based on number of jumps/landings so far
		if _landing_count == LANDING_REPEAT - 1:
			_anim.play("attack_landing_final")
		else:
			_anim.play("attack_landing_normal")
		
		_landing_count += 1
	else:
		_landing_count = 0
		_anim.play("attack_middle")

# Spawn temp projectiles at random locations
func _attack_middle_start():
	for i in NUM_TEMP_PROJ:
		_random.randomize()
		var x = _random.randi_range(X_LEFT_BOUND, X_RIGHT_BOUND)
		var y = _random.randi_range(Y_UP_BOUND, Y_DOWN_BOUND)
		var obj = TempProj.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = Vector2(x, y)
		
		obj.connect("destroyed", self, "_remove_projectile", [obj])
		_active_projectiles.append(obj)

# Have all active temp projectiles shoot at player
func _attack_middle_finish():
	for obj in _active_projectiles:
		obj.set_speed(TEMP_PROJ_SPEED)
		obj.dir = (player_obj.global_position - obj.global_position).normalized()

# Shoot split projectiles in fixed directions
func _attack_landing_split():
	for dir in _dirs:
		var obj = SplitProj.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir.normalized()

# Shoot normal projectiles in fixed directions
func _attack_landing_normal():
	for dir in _dirs:
		var obj = NormProj.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir.normalized()

# Shoot normal projectile at player
func _attack_landing_final():
	var obj = NormProj.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = _spawn_pos.global_position
	obj.dir = (player_obj.global_position - global_position).normalized()

# Remove projectile from array of active projectiles once it gets destroyed
func _remove_projectile(obj):
	_active_projectiles.erase(obj)

# Activate phase two and start animation
func _activate_phase_two():
	_phase_two_active = true
	_anim.play("activate_phase_two")
	
	# Spawn clones
	for pos in CLONE_POS:
		var clone = Clone.instance()
		get_tree().get_root().add_child(clone)
		clone.global_position = pos
		_active_clones.append(clone)

# Play phase two idle anim
func _phase_two_idle():
	_anim.play("phase_two_idle")

# Shoot projectile in random direction
func _attack_random():
	_random.randomize()
	var x = _random.randf_range(-10, 10)
	var y = _random.randf_range(-10, 10)
	
	var obj = NormProj.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = _spawn_pos.global_position
	obj.dir = Vector2(x, y).normalized()

# Override knockback to apply knockback in phase one, do not apply knockback in phase two
func apply_knockback(knockback_vector, knockback_strength):
	if _phase_two_active or _curr_hp <= PHASE_TWO_THRESHOLD:
		return
	
	# Only applies knockback if it is greater knockback than enemy's curr knockback
	if knockback_strength > curr_knockback_strength:
		curr_knockback_strength = knockback_strength
		knockback = knockback_vector.normalized() * curr_knockback_strength

# Override update_health to remove clones on death
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
		for clone in _active_clones:
			clone.queue_free()
		
		# Instance death effect before removing enemy
		var death = load(_death_path).instance()
		get_tree().current_scene.add_child(death)
		death.global_position = global_position
		
		queue_free()
