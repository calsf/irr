# LEVEL 3 BOSS BEHAVIOR
# PHASE ONE:
# Chase player while shooting projectiles in fixed direction
# PHASE TWO:
# Same as phase one but will move faster and shoot at a faster rate
extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 400
const PHASE_TWO_BONUS_SPEED = 30

export var proj_path : String

onready var DamageObject = load(proj_path)
onready var _spawn_pos = $Body/Attack/SpawnPos

var is_phase_two = false
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

# Called when the node enters the scene tree for the first time.
func _ready():
	enter_idle_state()

# Move to player movement
func _move(delta, other):
	# Transition to phase two once reached threshold
	if not is_phase_two and _curr_hp <= PHASE_TWO_THRESHOLD:
		is_phase_two = true
		_anim.play("move_alt")	# Play alternate move animation which will attack faster
		_move_speed += PHASE_TWO_BONUS_SPEED	# Increase move speed
	
	velocity = (player_obj.global_position - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed

# Shoot projectiles in fixed directions
func _attack_fixed():
	for dir in _dirs:
		var obj = DamageObject.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir.normalized()

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
