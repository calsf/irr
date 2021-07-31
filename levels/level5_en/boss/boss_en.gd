# LEVEL 5 BOSS BEHAVIOR
# PHASE ONE:
# Remains stationary, continuously spawn temporary projectiles at player position
# Temporary projectile spawns will predict ahead of player
# Will periodically teleport to player and absorb all active projectiles to self
# Cannot be knocked back during absorb attack
# PHASE TWO:
# Start moving to random positions
# Will periodically shoot split projectiles in fixed directions
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 1500

# Movement bounds
const X_RIGHT_BOUND = 265
const X_LEFT_BOUND = -265
const Y_UP_BOUND = -184
const Y_DOWN_BOUND = 192

# Time in between finding new position to move to
const MOVE_TIME_MIN = 3
const MOVE_TIME_MAX = 9

# Attack rates
const STILL_ATK_RATE = .7
const ABSORB_RATE = 15

# Offset position of still projectile spawn
const OFFSET = Vector2(0, -14)

# Dist to spawn projectile ahead of player
const AHEAD = 72

# Base speed of projectiles to be absorbed
const ABSORB_PROJ_SPEED = 100

export var proj_path_still : String
export var proj_path_split : String
onready var StillProj = load(proj_path_still)
onready var SplitProj = load(proj_path_split)

onready var _shadow_sprite = $Shadow
onready var _spawn_pos = $Body/Attack/SpawnPos
onready var _atk_timer = $Body/Attack/AttackTimer
onready var _atk_timer_absorb = $AttackTimerAbsorb
onready var _move_timer = $MoveTimer

var _active_projectiles = []
var _knockback_disabled = false
var _is_absorbing = false
var _curr_target_pos = Vector2.ZERO
var _random = RandomNumberGenerator.new()
var _phase_two_active = false
var _face_moving = false
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

func _ready():
	enter_idle_state()
	_atk_timer.connect("timeout", self, "_still_attack")
	_atk_timer_absorb.connect("timeout", self, "_disappear")
	
	Texture_Left = load(_left_path)
	Texture_Right = load(_right_path)

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
	
	# If within range of target pos, find a new position
	if _phase_two_active and global_position.distance_to(_curr_target_pos) < 20:
		_get_new_pos()

# Enter phase depending on health and start attacking
func _enter_phase():
	if _curr_hp <= PHASE_TWO_THRESHOLD:	# Enter phase two
		_phase_two_active = true
		_face_moving = true
		_atk_timer.stop()
		_atk_timer_absorb.stop()
		enter_move_state()
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
	
	_knockback_disabled = true # Do not allow knockback until absorb attack is finished
	_anim.play("reappear")
	
# Should be called after reappear animation to absorb all active projectiles
func _absorb_attack():
	_is_absorbing = true
	for proj in _active_projectiles:
		proj.dir = (_spawn_pos.global_position - proj.global_position).normalized()
		proj.set_speed(ABSORB_PROJ_SPEED)

# Finish absorb attack, should re-enter phase afterwards
func _finish_absorb():
	_knockback_disabled = false
	_is_absorbing = false
	_anim.play("finish_absorb")

# Remove projectile from array of active projectiles once it gets destroyed
func _remove_projectile(obj):
	_active_projectiles.erase(obj)

# Shoot split projectiles in fixed directions
func _split_attack():
	for dir in _dirs:
		var obj = SplitProj.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir.normalized()

# Get new target position to move to
func _get_new_pos():
	_random.randomize()
	var x = _random.randi_range(X_LEFT_BOUND, X_RIGHT_BOUND)
	var y = _random.randi_range(Y_UP_BOUND, Y_DOWN_BOUND)
	_curr_target_pos = Vector2(x, y)
	
	_random.randomize()
	var time = _random.randi_range(MOVE_TIME_MIN, MOVE_TIME_MAX)
	_move_timer.start(time)

# In move state, will always move towards target position
func _move(delta, other):
	# Only move during phase two
	if not _phase_two_active:
		return
	
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
						
	velocity = (_curr_target_pos - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed

# Update health by adding change value to curr_hp
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
		
		# Adjust death effect to have same texture and facing direction as enemy
		death.get_node("Death").texture = _body_sprite.texture
		death.get_node("Death").scale.x = _body_sprite.scale.x
		
		queue_free()

# Called by damaging objects to apply knockback to this enemy
func apply_knockback(knockback_vector, knockback_strength):
	# Do not apply knockback during absorb attack
	if _knockback_disabled:
		return
		
	# Only applies knockback if it is greater knockback than enemy's curr knockback
	if knockback_strength > curr_knockback_strength:
		curr_knockback_strength = knockback_strength
		knockback = knockback_vector.normalized() * curr_knockback_strength


