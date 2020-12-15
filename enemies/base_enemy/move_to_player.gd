# Still enemy that activates and moves to player when aggro'd
extends Enemy
class_name MoveToPlayer

func _ready():
	# Start and remain in idle until aggro
	enter_idle_state()
	
	# Enter activate state/play activate anim upon aggro
	# Activate anim should enter_move_state() once finished
	connect("aggro_started", self, "enter_activate_state")

func _move(delta, other):
	velocity = (player_obj.global_position - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed
