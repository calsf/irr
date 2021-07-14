# Special behavior for enemy
# Move to player, also increase move speed based on remaining health
extends Enemy
class_name FlamingSkull

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

# Override update_health to also update move speed based on remaining health
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
		
		queue_free()
	elif change < 0:
		update_move_speed()

func update_move_speed():
	# Limit to lowest health possible that can increase move speed
	# Allows for faster increase from earlier health loss
	if _curr_hp < (_enemy_props.max_hp / 2):
		return
	
	var health_multiplier = (float(_enemy_props.max_hp) / float(_curr_hp))
	_move_speed = float(_enemy_props.move_speed) * health_multiplier
