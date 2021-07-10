extends Enemy

# Health or below to trigger phase two behavior
const PHASE_TWO_THRESHOLD = 2000

# Bounds for still projectile to spawn
const X_RIGHT_BOUND = 256
const X_LEFT_BOUND = -256
const Y_UP_BOUND = -164
const Y_DOWN_BOUND = 184

const ATTACK_RATE = 3

export var enemy_spawn_path : String
onready var EnemySpawn = load(enemy_spawn_path)

onready var _atk_timer = $Body/Attack/AttackTimer

var phase_two_active = false
var _random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_atk_timer.connect("timeout", self, "_attack")

func _physics_process(delta):
	# Start phase two attack once hp threshold is reached
	# _start_phase_two called in animation to start attacking
	if not phase_two_active and _curr_hp <= PHASE_TWO_THRESHOLD:
		_anim.play("phase_two_activate")
		phase_two_active = true

func _attack():
	if phase_two_active:
		_spawn_enemy_spawn()
		_spawn_enemy_spawn()
		_atk_timer.start(ATTACK_RATE - .5)
	else:
		_spawn_enemy_spawn()
		_atk_timer.start(ATTACK_RATE)

# Spawns an EnemySpawn object at random location
func _spawn_enemy_spawn():
	_random.randomize()
	var x = _random.randi_range(X_LEFT_BOUND, X_RIGHT_BOUND)
	var y = _random.randi_range(Y_UP_BOUND, Y_DOWN_BOUND)
	
	var obj = EnemySpawn.instance()
	get_parent().add_child(obj)
	obj.owner = get_owner()
	obj.global_position = Vector2(x, y)

# Override apply knockback to do nothing - this boss cannot be knocked back
func apply_knockback(knockback_vector, knockback_strength):
	pass

# Override update health to also destroy any enemies when boss is killed
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
		# Check for all enemies that are not self and effectively update health to 0
		for obj in get_parent().get_children():
			if obj != self and obj is Enemy:
				obj.update_health(-obj._curr_hp)
		
		# Instance death effect before removing enemy
		var death = load(_death_path).instance()
		get_tree().current_scene.add_child(death)
		death.global_position = global_position
		
		queue_free()
	
