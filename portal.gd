# Portal should only detect Player entering area
extends Node2D

const OFFSET = 16

var dest_loc = Vector2.ZERO
var dest_room_id = 0
var move_dir = Vector2.ZERO

func _process(delta):
	# Gets direction player is moving in, will not reset to zero
	var new_dir = Vector2.ZERO
	new_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	new_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# If player is not moving, will not set new direction, this way we keep player's last moving dir
	if new_dir != Vector2.ZERO:
		move_dir = new_dir.normalized()

# When player enters portal, teleport player to location and set their room id accordingly
func _on_EnterArea_area_entered(area):
	var player = area.get_owner()
	
	# Offset destination location by player's last moving direction multiplied by OFFSET
	# Offset must be enough to avoid player looping back between portals upon teleporting
	var dest_offset = move_dir.normalized() * OFFSET
	player.global_position = dest_loc + dest_offset
	player.curr_room_id = dest_room_id
