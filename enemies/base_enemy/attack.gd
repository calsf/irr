# Should be attached to the Attack component of an enemy
# Owner should be main enemy
extends Node

export var proj_path : String
export var atk_rate : float			# The normal time between attacks
export var first_atk_delay : float	# Time to delay first attack by

onready var DamageObject = load(proj_path)
onready var _spawn_pos = $SpawnPos
onready var _atk_timer = $AttackTimer
onready var _atk_anim = $AttackAnimation
onready var _enemy = get_owner()

func _ready():
	# When timer runs out, attack
	_atk_timer.connect("timeout", self, "_start_atk")
	
	# When enemy first aggros on player, delay the first attack by first_atk_delay
	_enemy.connect("aggro_started", self, "_delay_first_atk")

# Spawn dmg obj in given direction(s), should be called in animation
func _attack_fixed(dirs : Array):
	for dir in dirs:
		var obj = DamageObject.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = _spawn_pos.global_position
		obj.dir = dir.normalized()

# Attack player
func _attack_player():
	var obj = DamageObject.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = _spawn_pos.global_position
	obj.dir = (_enemy.player_obj.global_position - _spawn_pos.global_position).normalized()

# Attack when timer runs out
func _start_atk():
	_atk_anim.play("attack")
	
	# Attack delay starts at START OF ANIMATION, so consider anim time into delay
	_atk_timer.start(atk_rate)

# Delays first attack by first_atk_delaytime
func _delay_first_atk():
	_atk_timer.start(first_atk_delay)

# Make enemy enter move state - should be called at end of attack anim if needed
func _start_moving():
	_enemy.enter_move_state() 

# Make enemy enter stop state - should called at start of attack anim if needed
# Will stop parent animation and stop enemy movement
func _stop_moving():
	_enemy.enter_stop_state() 
	
