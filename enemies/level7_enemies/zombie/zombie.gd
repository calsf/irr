# Special behavior for enemy
# Move to player, also attack player when hit
extends Enemy
class_name Zombie

export var dirs : Array

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

# Overriding update_health to attack after being hit
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
		_attack_sprite.call_deferred("_attack_fixed", dirs)

