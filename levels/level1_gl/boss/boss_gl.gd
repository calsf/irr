# LEVEL 1 BOSS BEHAVIOR
# PHASE ONE:
# Stay in place
# Repeatedly normal attack, shooting projectiles in fixed direction
# After ABSORB_PER_ATTACK_PHASE_ONE normal attacks, absorb attack, which will
# pull all active projectiles towards self
# PHASE TWO:
# Similar to Phase One but will now burrow before each attack
# Will reappear at random position or player position depending on attack counter
extends Enemy

# Number of normal attacks for each phase before absorbing
const ABSORB_PER_ATTACK_PHASE_ONE = 10
const ABSORB_PER_ATTACK_PHASE_TWO = 3

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 1000

# Max X and Y boundaries that boss can reappear at
const X_RIGHT_BOUND = 244
const X_LEFT_BOUND = -244
const Y_UP_BOUND = -178
const Y_DOWN_BOUND = 188

export var proj_path : String

onready var DamageObject = load(proj_path)
onready var _spawn_pos = $Body/ShootSpawn

var _rng = RandomNumberGenerator.new()
var _is_absorbing = false
var _attack_counter = 0
var _active_projectiles = []
var _possible_dir = [
	[Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), 
		Vector2(.5, .5), Vector2(-.5, .5), Vector2(-.5, -.5), Vector2(.5, -.5)],
	
	[Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), 
		Vector2(.65, .65), Vector2(-.65, .65), Vector2(-.65, -.65), Vector2(.65, -.65),
		Vector2(1, .5), Vector2(-1, .5), Vector2(1, -.5), Vector2(-1, -.5)],
	
	[Vector2(.4, .3), Vector2(.4, -.3), Vector2(-.4, .3), Vector2(-.4, -.3), 
		Vector2(.65, .65), Vector2(-.65, .65), Vector2(-.65, -.65), Vector2(.65, -.65),
		Vector2(.75, .5), Vector2(-.75, .5), Vector2(.75, -.5), Vector2(-.75, -.5)],
		
	[Vector2(.75, 0), Vector2(-.75, 0), Vector2(0, -1), Vector2(0, 1), 
		Vector2(.5, .75), Vector2(-.5, .75), Vector2(-.5, -.75), Vector2(.5, -.75)],
	
	[Vector2(.75, .25), Vector2(-.75, .25), Vector2(.75, -.25), Vector2(-.75, -.25), 
		Vector2(0, -1), Vector2(0, 1), 
		Vector2(.25, .75), Vector2(-.25, .75), Vector2(-.25, -.75), Vector2(.25, -.75)],
	
	[Vector2(.5, .1), Vector2(-.5, .1), Vector2(.5, -.1), Vector2(-.5, -.1), 
		Vector2(.25, -.5), Vector2(.25, .5), Vector2(-.25, -.5), Vector2(-.25, .5), 
		Vector2(.5, .5), Vector2(-.5, .5), Vector2(-.5, -.5), Vector2(.5, -.5)],
	
	[Vector2(.5, .1), Vector2(-.5, .1), Vector2(.5, -.1), Vector2(-.5, -.1), 
		Vector2(.1, -.5), Vector2(.1, .5), Vector2(-.1, -.5), Vector2(-.1, .5), 
		Vector2(.25, .25), Vector2(-.25, .25), Vector2(-.25, -.25), Vector2(.25, -.25)],
	
	[Vector2(.2, .35), Vector2(-.2, .35), Vector2(.2, -.35), Vector2(-.2, -.35), 
		Vector2(.1, -.25), Vector2(.1, .25), Vector2(-.1, -.25), Vector2(-.1, .25), 
		Vector2(.25, .1), Vector2(-.25, .1), Vector2(-.25, -.1), Vector2(.25, -.1),
		Vector2(.35, .2), Vector2(-.35, .2), Vector2(.35, -.2), Vector2(-.35, -.2),
		Vector2(.4, 0), Vector2(-.4, 0), Vector2(0, -.4), Vector2(0, .4), ],
]

func _physics_process(delta):
	# Faster anim in phase two
	if _curr_hp <= PHASE_TWO_THRESHOLD:
		_anim.playback_speed = 1.5
		
	# While absorbing
	if _is_absorbing:
		# Check if all projectiles have been 'absorbed'
		if _active_projectiles.size() == 0:
			_is_absorbing = false
			_after_attack()
		
		# For each active projectile, gradually increase speed
		# Also check if projectile is close to spawn position, if so, destroy projectile
		for proj in _active_projectiles:
			proj.dir = proj.dir * 1.02
			if proj.global_position.distance_to(_spawn_pos.global_position) < 15:
				_remove_projectile(proj)
				proj.queue_free()

# For phase two, before every attack, burrow underground
func _burrow():
	_anim.play("burrow")

# Reappear from underground
func _reappear():
	if _attack_counter >= ABSORB_PER_ATTACK_PHASE_TWO:		# Reappear at player position
		# Set position equal to player's position, clamping for position boundaries
		global_position.x = clamp(player_obj.global_position.x, X_LEFT_BOUND, X_RIGHT_BOUND)
		global_position.y = clamp(player_obj.global_position.y, Y_UP_BOUND, Y_DOWN_BOUND)
	else:		# Reappear at random position
		_rng.randomize()
		var x = _rng.randi_range(X_LEFT_BOUND, X_RIGHT_BOUND)
		var y = _rng.randi_range(Y_UP_BOUND, Y_DOWN_BOUND)
		global_position = Vector2(x, y)
	
	_anim.play("reappear")

# Start normal attack
func _start_normal_attack():
	_anim.play("normal_attack")
	
# Part of normal attack, spawn dmg obj in given direction(s), should be called in animation
func _attack_fixed():
	# Increment attack counter
	_attack_counter = _attack_counter + 1
	
	# Randomly select one of possible directions
	randomize()
	var selected_dir = _possible_dir[randi() % _possible_dir.size()]
	
	for dir in selected_dir:
		var obj = DamageObject.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir # No normalization
		
		obj.connect("destroyed", self, "_remove_projectile", [obj])
		_active_projectiles.append(obj)
	
	# Shoot extra projectiles if in phase two
	if _curr_hp <= PHASE_TWO_THRESHOLD:
		# Randomly select A DIFFERENT set of possible directions
		var extra_selected_dir = selected_dir
		while extra_selected_dir == selected_dir:
			randomize()
			extra_selected_dir = _possible_dir[randi() % _possible_dir.size()]
		
		for dir in extra_selected_dir:
			var obj = DamageObject.instance()
			get_tree().get_root().add_child(obj)
			obj.global_position = _spawn_pos.global_position
			obj.dir = dir # No normalization
			
			obj.connect("destroyed", self, "_remove_projectile", [obj])
			_active_projectiles.append(obj)

# Called after an attack ends
# If in phase two, should burrow before next attack
func _after_attack():
	if _curr_hp <= PHASE_TWO_THRESHOLD:
		_burrow()
	else:
		_check_next_attack()

# Check for next attack
# Use attack counter to see if should transition to absorb attack or continue normal
# Used in _after_attack, but should also use at end of reappear animation
func _check_next_attack():
	if (_curr_hp > PHASE_TWO_THRESHOLD and _attack_counter >= ABSORB_PER_ATTACK_PHASE_ONE) \
		or (_curr_hp <= PHASE_TWO_THRESHOLD and _attack_counter >= ABSORB_PER_ATTACK_PHASE_TWO):
		_anim.play("absorb_start")
		_attack_counter = 0
	else:
		_start_normal_attack()

# Absorb all current active enemy projectiles towards self
func _attack_absorb():
	_is_absorbing = true
	_anim.play("absorb_attack")
	for proj in _active_projectiles:
		proj.dir = (_spawn_pos.global_position - proj.global_position).normalized()

# Remove projectile from array of active projectiles once it gets destroyed
func _remove_projectile(obj):
	_active_projectiles.erase(obj)

# Override apply knockback to do nothing - this boss cannot be knocked back
func apply_knockback(knockback_vector, knockback_strength):
	pass
