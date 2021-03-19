extends Node2D

export var restore_amount = 0
export var sound_name = ""
onready var _pickup_area = $PickupArea

func _physics_process(delta):
	var overlapping_areas = _pickup_area.get_overlapping_areas()
	
	# Use health pickup if player overlapping and has lost health
	if overlapping_areas and PlayerHealth.curr_hp < PlayerHealth.MAX_HP:
		PlayerHealth.add_health(restore_amount)
		queue_free()
		
		GlobalSounds.play(sound_name)
