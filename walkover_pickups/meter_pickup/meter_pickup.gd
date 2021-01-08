extends Node2D

export var restore_amount = 0
onready var _pickup_area = $PickupArea

func _physics_process(delta):
	var overlapping_areas = _pickup_area.get_overlapping_areas()
	
	# Use meter pickup if player overlapping and is below max meter
	if overlapping_areas and PlayerMeter.curr_meter < PlayerMeter.MAX_METER:
		PlayerMeter.add_meter(restore_amount)
		queue_free()
