# Chase player once player comes into the detect area of this enemy
extends Enemy

onready var _detect_area = $Detectbox
var activated = false

func _ready():
	# Start in idle state
	enter_idle_state()

func _physics_process(delta):
	# Check if player is in detect area and start chase if true by entering activate state
	# Also make sure player is in same room as enemy
	var areas = _detect_area.get_overlapping_areas()
	if room_id == PlayerRoom.curr_room_id and not activated and areas:
		activated = true
		enter_activate_state()

func _move(delta, other):
	velocity = (player_obj.global_position - global_position).normalized() * _move_speed
	velocity = move_and_slide(velocity)
	
	# When moving to player, enemies may stack on top of eachother
	# Apply other vector to position which is push vector to prevent stacking
	global_position += other * delta * _move_speed
