# Portal should only detect Player entering area
extends Node2D

const OFFSET = 16

onready var enter_area = $EnterArea/CollisionShape2D
onready var anim = $AnimationPlayer
var camera = null

var dest_portal = null
var dest_loc = Vector2.ZERO
var dest_room = null
var move_dir = Vector2.ZERO

func _ready():
	camera = get_tree().current_scene.get_node("Camera2D")

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
	player.curr_room_id = dest_room.room_id
	
	# Disable the destination room portals upon entering if they should be locked
	# The room should handle unlocking portals once a condition is met
	if dest_room.is_locked:
		dest_room.lock_portals()
	
	# Move camera to destination room position
	camera.global_position = dest_room.global_position

# Disables self, NO ANIMATION
func disable_portal():
	self.visible = false
	enter_area.disabled = true

# Enables self and destination portal
func enable_portal():
	self.visible = true
	enter_area.disabled = false
	anim.play("start")
	
	dest_portal.visible = true
	dest_portal.enter_area.disabled = false
	dest_portal.anim.play("start")

# Disables and plays lock animation
func disable_with_anim():
	enter_area.call_deferred("set_disabled", true)
	anim.play("lock")
	
