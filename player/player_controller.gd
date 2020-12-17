extends KinematicBody2D

#const BASE_SPEED = 32 * 10
const BASE_SPEED = 32 * 5

# Player sprite textures with lighting on opposite sides for when player flips
var Texture_Left = preload("res://player/player_left.png")
var Texture_Right = preload("res://player/player_right.png")

var move_speed = BASE_SPEED
var input_vector = Vector2()
var curr_interactable = null
var curr_room_id = 0	# rooom id player is currently in, starts in room 0

onready var _sprite = $Sprite
onready var _anim = $AnimationPlayer
onready var _interact_area = $InteractArea
onready var weapons = $Weapons.get_children()
onready var weapon_primary : Weapon
onready var weapon_secondary : Weapon
onready var weapon_curr : Weapon

# Signals to update HUD
signal primary_selected()
signal secondary_selected()
signal primary_swapped()
signal secondary_swapped()

# Called when the node enters the scene tree for the first time.
func _ready():
	_interact_area.connect("area_entered", self, "_enter_interact")
	_interact_area.connect("area_exited", self, "_exit_interact")
	
	weapon_primary = weapons[0]
	weapon_secondary = weapons[1]
	weapon_curr = weapon_primary
	weapon_curr.visible = true
	
	emit_signal("primary_selected")
	# Make sure to emit swapped signals with swapped weapon's icon path
	emit_signal("primary_swapped", weapon_primary.weapon_props.icon_path)
	emit_signal("secondary_swapped", weapon_secondary.weapon_props.icon_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Movement
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	input_vector = move_and_slide(input_vector.normalized() * move_speed)
	if input_vector == Vector2.ZERO:
		_anim.play("Idle")
	else:
		_anim.play("Walk")
		
	# Mouse facing direction
	var mouse_dir = get_global_mouse_position() - global_position
	var rot = rad2deg(atan2(mouse_dir.y, mouse_dir.x))
		
	# Player facing direction to match mouse facing direction
	# Sprite texture changed depending on facing direction to maintain lighting
	if mouse_dir.x < 0:
		_sprite.texture = Texture_Left
		if (_sprite.scale.x < 0):
			_sprite.scale.x *= -1
	else:
		_sprite.texture = Texture_Right
		if (_sprite.scale.x > 0):
			_sprite.scale.x *= -1

# Get input events
func _input(event):
	# Attack inputs for current weapon
	if event.is_action_pressed("normal_attack"):
		weapon_curr.normal_attack()
	if event.is_action_pressed("empowered_attack"):
		weapon_curr.empowered_attack()
	
	# Switch selected weapons
	if event.is_action_pressed("toggle_weapon"):
		weapon_curr.visible = false
		if (weapon_curr == weapon_primary):
			weapon_curr = weapon_secondary
			emit_signal("secondary_selected")
		else:
			weapon_curr = weapon_primary
			emit_signal("primary_selected")
		weapon_curr.visible = true
	
	# If in interactable area, listen for player input
	if curr_interactable and event.is_action_pressed("interact"):
		if curr_interactable.is_in_group("pickups"):
			# weapon_id should match the object's index in Weapons children
			# NOTE: Empty weapon takes up index 0 and 1, weapons start at index 2
			var new_weapon = weapons[curr_interactable.weapon_id]
			
			# Do not replace weapon if already used in primary or secondary slot
			if new_weapon == weapon_primary || new_weapon == weapon_secondary:
				# Already owned, should not be happening since no duplicate pickups
				return
			else:	# Replace current weapon
				weapon_curr.visible = false
				
				# If curr is not empty, replace pickup with curr weapon's pickup
				if weapon_curr.weapon_props.pickup_path != "":
					# Replace pickup with the replaced weapon's pickup
					var replaced_pickup = load(weapon_curr.weapon_props.pickup_path).instance()
					get_tree().current_scene.add_child(replaced_pickup)
					replaced_pickup.global_position = curr_interactable.global_position
				
				if weapon_curr == weapon_primary:
					weapon_primary = new_weapon
					emit_signal("primary_swapped", weapon_primary.weapon_props.icon_path)
				else:
					weapon_secondary = new_weapon
					emit_signal("secondary_swapped", weapon_secondary.weapon_props.icon_path)
				weapon_curr = new_weapon
				
				weapon_curr.visible = true
				
				# Remove pickup
				curr_interactable.queue_free()
			

# Sets curr_interactable when entering an interactable area
func _enter_interact(area):
	curr_interactable = area.get_owner()

# Resets curr_interactable when leaving an interactable area
func _exit_interact(area):
	# Only set to null if exiting the same interactable area as the curr
	if area == curr_interactable:
		curr_interactable = null
