extends Area2D

const MAX_HP = 3
const INVULN_TIME = 1

onready var hurt_timer = $HurtTimer

var curr_hp = MAX_HP
var is_invuln = false

func _physics_process(delta):
	# If not invulnerable, check for overlapping areas
	# If has any overlapping areas, deal damage to player and start invuln time
	# Must make sure collision mask is set to layers that will damage player
	if not is_invuln:
		var overlapping_areas = get_overlapping_areas()
		
		if overlapping_areas:
			is_invuln = true
			curr_hp -= 1
			hurt_timer.start(INVULN_TIME)

# When hurt timer runs out, player can take damage again
func _on_HurtTimer_timeout():
	is_invuln = false
