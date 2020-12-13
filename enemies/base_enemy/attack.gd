extends Node

export var proj_path : String
export var atk_rate : float

onready var DamageObject = load(proj_path)
onready var _spawn_pos = $SpawnPos
onready var _atk_timer = $AttackTimer
onready var _atk_anim = $AttackAnimation

var _attacking = false
var _is_aggro = true

func _ready():
	_atk_timer.connect("timeout", self, "_reset_atk")

func _process(delta):
	# If aggro'd on player but not attacking, attack and start delay
	if _is_aggro and not _attacking:
		_attacking = true
		_start_atk()
		
		# Attack delay starts at START OF ANIMATION, so consider anim time into delay
		_atk_timer.start(atk_rate)

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
	obj.dir = (get_owner().player_obj.global_position - _spawn_pos.global_position).normalized()

# Play attack animation
func _start_atk():
	_atk_anim.play("attack")

# Reset attacking to false to reset attack timer
func _reset_atk():
	_attacking = false

# Make enemy enter move state - should be called at start of attack anim if needed
func _start_moving():
	get_owner().enter_move_state() 

# Make enemy enter stop state - should called at end of attack anim if needed
func _stop_moving():
	get_owner().enter_stop_state() 
	
