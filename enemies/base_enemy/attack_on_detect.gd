# Should be attached to the Attack component of an enemy
# Owner should be main enemy
# Perform an attack whenever player comes into the detect area of this enemy
extends Node

onready var _enemy = get_owner()
onready var _atk_anim = $AttackAnimation
onready var _detect_area = _enemy.get_node("Detectbox")

func _physics_process(delta):
	# If not currently attacking, check if player is in detect area and attack if true
	if _atk_anim.current_animation != "attack":
		var areas = _detect_area.get_overlapping_areas()
		if areas:
			_atk_anim.play("attack")

# Make enemy enter move state - should be called at end of attack anim if needed
func _start_moving():
	_enemy.enter_move_state() 

# Make enemy enter stop state - should called at start of attack anim if needed
# Will stop parent animation and stop enemy movement
func _stop_moving():
	_enemy.enter_stop_state() 
