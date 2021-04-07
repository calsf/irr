extends KinematicBody2D

#const BASE_SPEED = 32 * 10
const BASE_SPEED = 32 * 5
const BASE_DODGE_SPEED = 32 * 10

# Player sprite textures with lighting on opposite sides for when player flips
var Texture_Left = preload("res://player/player_left.png")
var Texture_Right = preload("res://player/player_right.png")

var Damaged = preload("res://player/player_damaged_shader.tres")

var move_speed = BASE_SPEED
var input_vector = Vector2()
var curr_interactable = null
var can_act = false
var is_dodge_moving = false	# If player is locked in dodge/invuln part of dodge
var is_dodging = false	# If player is still in dodge anim at all

onready var _sprite = $Sprite
onready var _shadow = $Shadow
onready var _anim = $AnimationPlayer
onready var _interact_area = $InteractArea
onready var _hurtbox = $PlayerHurtbox
onready var weapons = $Weapons.get_children()
onready var weapon_primary : Weapon
onready var weapon_secondary : Weapon
onready var weapon_curr : Weapon

# Load saved data - need for equipped weapons
# MAY NEED TO RELOAD IN CASE SOMETHING ELSE UPDATES SAVE_DATA
# weapons should be ordered such that the index of child is same as the weapon's id
onready var save_data = SaveLoadManager.load_data()

# Scene sounds
onready var _sounds = $Sounds

# Signals to update HUD
signal primary_selected()
signal secondary_selected()
signal primary_swapped()
signal secondary_swapped()

# Signal emitted after player's entrance animation
signal has_started()

# Signal emitted after player enters new room, should send new room id
signal entered_room()

# Signal emitted after player falls
signal player_fell()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize values
	PlayerMeter.curr_meter = 0
	PlayerHealth.curr_hp = PlayerHealth.MAX_HP
	
	_interact_area.connect("area_entered", self, "_enter_interact")
	_interact_area.connect("area_exited", self, "_exit_interact")
	
	# Player hurtbox should send signal when player loses health
	_hurtbox.connect("player_hurt", self, "_flash_damaged")
	
	# Player hurtbox should send signal when player invuln time is over
	_hurtbox.connect("invuln_finished", self, "_reset_alpha")
	
	_anim.connect("animation_finished", self, "_has_started")
	
	weapon_primary = weapons[save_data["primary_weapon_id"]]
	weapon_secondary = weapons[save_data["secondary_weapon_id"]]
	weapon_curr = weapon_primary
	
	# Wait until PlayerHUD is ready and connected to player_controller before emitting signal
	yield(get_tree().current_scene.get_node("CanvasLayer/PlayerHUD"), "ready")
	emit_signal("primary_selected")
	# Make sure to emit swapped signals with swapped weapon's icon path
	emit_signal("primary_swapped", weapon_primary.weapon_props.icon_path)
	emit_signal("secondary_swapped", weapon_secondary.weapon_props.icon_path)
	
	PlayerHealth.connect("player_died", self, "_player_die")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not can_act:
		return
	
	# Normal movement
	if not is_dodge_moving:	# Not locked in dodge movement, move via input
		input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		input_vector = input_vector.normalized()
		input_vector = move_and_slide(input_vector.normalized() * move_speed)
	else:	# Player is locked in dodge movement
		input_vector = move_and_slide(input_vector.normalized() * BASE_DODGE_SPEED)
	
	if not is_dodging: 	# If not dodging, is either walking or idle
		if input_vector == Vector2.ZERO:
			_anim.play("Idle")
		else:
			_anim.play("Walk")
		
		weapon_curr.show_front_par()
	else:
		weapon_curr.show_behind_par()
		
	# Mouse facing direction
	var mouse_dir = get_global_mouse_position() - global_position
		
	# Player facing direction to match mouse facing direction
	# Sprite texture changed depending on facing direction to maintain lighting
	if mouse_dir.x < 0:
		_sprite.texture = Texture_Left
		if (_sprite.scale.x < 0):
			_shadow.scale.x *= -1
			_sprite.scale.x *= -1
	else:
		_sprite.texture = Texture_Right
		if (_sprite.scale.x > 0):
			_shadow.scale.x *= -1
			_sprite.scale.x *= -1
	
	# Normal attack input for current weapon, can be held down
	if Input.is_action_pressed("normal_attack"):
		weapon_curr.normal_attack()

# Check input events when they are dispatched
func _input(event):
	if not can_act:
		return
	
	# Dodge input, player must dodge in a direction and cannot be already dodging
	if event.is_action_pressed("dodge") and input_vector != Vector2.ZERO and not is_dodging:
		_anim.play("Dodge")
		is_dodging = true
		is_dodge_moving = true
		_sprite.set_modulate(Color(1, 1, 1, .3))
	
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
	
	# Empowered attack inputs CANNOT be held down
	if event.is_action_pressed("empowered_attack"):
		weapon_curr.empowered_attack()
	
	# If in interactable area, listen for player input
	if curr_interactable and event.is_action_pressed("interact"):
		if curr_interactable.is_in_group("pickups"):	# Is a weapon pickup
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
					var par = curr_interactable.get_parent()
					par.add_child(replaced_pickup)
					replaced_pickup.global_position = curr_interactable.global_position
				
				if weapon_curr == weapon_primary:
					weapon_primary = new_weapon
					
					# Update current save data and save new equipped weapon
					save_data = SaveLoadManager.load_data()
					save_data["primary_weapon_id"] = new_weapon.weapon_props.weapon_id
					SaveLoadManager.save_data(save_data)
					
					# Emit signal AFTER updating save
					emit_signal("primary_swapped", weapon_primary.weapon_props.icon_path)
				else:
					weapon_secondary = new_weapon
					
					# Update current save data and save new equipped weapon
					save_data = SaveLoadManager.load_data()
					save_data["secondary_weapon_id"] = new_weapon.weapon_props.weapon_id
					SaveLoadManager.save_data(save_data)
					
					# Emit signal AFTER updating save
					emit_signal("secondary_swapped", weapon_secondary.weapon_props.icon_path)
				weapon_curr = new_weapon
				
				weapon_curr.visible = true
				
				# Remove pickup
				curr_interactable.queue_free()
		else:	# Else, non weapon pick up, call the interactable's interact
			curr_interactable.interact()		

# Sets curr_interactable when entering an interactable area
func _enter_interact(area):
	curr_interactable = area.get_owner()

# Resets curr_interactable when leaving an interactable area
func _exit_interact(area):
	# Only set to null if exiting the same interactable area as the curr
	if area.get_owner() == curr_interactable:
		curr_interactable = null

# Create flash effect by swapping material on sprites
# Will also make player transparent to indicate invuln after being damaged
# WILL NOT FLASH IF PLAYER SHOULD BE DEAD
func _flash_damaged():
	if PlayerHealth.curr_hp > 0:	# Only flash if player isn't dead
		_sounds.play("PlayerHurt")	# Hurt sound, does not play if player dies
		
		_sprite.material = Damaged
		yield(get_tree().create_timer(.05), "timeout")
		_sprite.material = null
		yield(get_tree().create_timer(.05), "timeout")
		_sprite.set_modulate(Color(1, 1, 1, .3))
		_sprite.material = Damaged
		yield(get_tree().create_timer(.1), "timeout")
		_sprite.material = null

# Reset transparency
func _reset_alpha():
	if not is_dodge_moving: # If player is in dodge movement, let it handle restoring alpha
		_sprite.set_modulate(Color(1, 1, 1, 1))

# Play death anim and stop player action
func _player_die():
	_anim.play("Dead")
	can_act = false
	weapon_curr.visible = false
	_hurtbox.get_node("CollisionShape2D").disabled = true
	
	# Player death sound
	_sounds.play("PlayerDeath")

# Movement portion of dodge is finished
# MOVEMENT PORTION IS ALSO THE INVULNERABLE PORTION OF DODGE
func _finish_dodge_movement():
	is_dodge_moving = false
	_sprite.set_modulate(Color(1, 1, 1, 1))

# The entire dodge animation is finished
func _finish_dodge():
	is_dodging = false

# Once start animation is finished, allow player to act
func _has_started(anim):
	if anim == "Start":
		weapon_curr.visible = true
		can_act = true
		emit_signal("has_started")

# Stop player from acting and pause movement and animation
func stop_player():
	can_act = false
	input_vector = Vector2.ZERO
	_anim.play("Idle")

# Play player falling animation
func player_fall():
	weapon_curr.visible = false
	_hurtbox.get_node("CollisionShape2D").disabled = true
	_shadow.visible = false
	_anim.play("Fall")

# Call in player fall animation
func player_fall_finished():
	emit_signal("player_fell")

# Move player to new position and assign curr room id to the new room id
func enter_room(new_pos, new_room_id):
	global_position = new_pos
	PlayerRoom.curr_room_id = new_room_id
	
	# Objects in rooms (i.e enemies) need to listen for when player enters a room
	emit_signal("entered_room", PlayerRoom.curr_room_id)
