# Still enemy that activates and moves to player when aggro'd
extends Enemy
class_name MoveToPlayer

var _is_activated = false

func _ready():
	# Start in idle
	enter_idle_state()

# Check for aggro and play activation anim if aggro'd
func _process(delta):
	if PlayerHealth.curr_hp < 3 and not _is_activated:
		_is_activated = true
		
		# Activate anim should enter call enter_move_state() once finished
		enter_activate_state()

func _move(delta, other):
	velocity = (player_obj.global_position - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed
