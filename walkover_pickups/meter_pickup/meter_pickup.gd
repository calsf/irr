extends Node2D

const SPEED = 64	# Speed of movement for 'dropping' from chest

export var restore_amount = 0
export var sound_name = ""
onready var _pickup_area = $PickupArea
onready var anim = $AnimationPlayer

# For 'drop' from chest movement
var target_pos = null
var dir = Vector2.ZERO

func _physics_process(delta):
	var overlapping_areas = _pickup_area.get_overlapping_areas()
	
	# Use meter pickup if player overlapping and is below max meter
	if overlapping_areas and PlayerMeter.curr_meter < PlayerMeter.MAX_METER:
		PlayerMeter.add_meter(restore_amount)
		queue_free()
		
		GlobalSounds.play(sound_name)
	
	# For 'drop' from chest movement
	if target_pos != null:
		if global_position.distance_to(target_pos) < 10:
			target_pos = null
			return
		else:
			global_position += (dir * SPEED) * delta

# 'Drop' the pickup, disabled interact until finished
func drop():
	_pickup_area.get_node("CollisionShape2D").disabled = true
	anim.play("drop")

# Enter idle state, enable interact area
func _enter_idle():
	_pickup_area.get_node("CollisionShape2D").disabled = false
	anim.play("idle")
