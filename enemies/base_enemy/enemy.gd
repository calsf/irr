# Base class for enemies
extends KinematicBody2D
class_name Enemy

const DECEL = 500
const DISPLAY_TIME = 3
const FLASH_TIME = .1

var Damaged = preload("res://enemies/base_enemy/enemy_damaged_shader.tres")

export var _enemy_props : Resource
export var _death_path : String	# Death scene
export var _left_path : String	# Left facing sprite path
export var _right_path : String	# Right facing sprite path
export var _face_player : bool	# Face player if true

onready var _curr_hp = _enemy_props.max_hp
onready var _move_speed = _enemy_props.move_speed
onready var _body_sprite = $Body
onready var _attack_sprite = $Body/Attack
onready var _pushbox = $Pushbox
onready var _health_display = $HealthDisplay
onready var _health_fill = $HealthDisplay/HealthFill
onready var _health_bg = $HealthDisplay/HealthBG
onready var _health_timer = $HealthDisplayTimer
onready var _anim = $AnimationPlayer
onready var _flash_timer = $FlashTimer

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var curr_knockback_strength = 0
var _health_ratio = 0
var is_move_state = true
var is_aggro = false

# Sprite textures for lighting when facing directions
# Not needed if _face_player is false
var Texture_Left = null
var Texture_Right = null

# Reference to player should be set by player
var player_obj = null

# The room id this enemy belongs to
var room_id

# Emit signal when enemy first aggros onto player
signal aggro_started()

func _ready():
	_flash_timer.connect("timeout", self, "_reset_material")
	
	# Set health amount to health fill ratio
	_health_ratio = _curr_hp / _health_bg.rect_size.x
	_health_timer.connect("timeout", self, "_hide_health")
	_health_display.visible = false
	
	# Only load if need to face player
	if _face_player:
		Texture_Left = load(_left_path)
		Texture_Right = load(_right_path)
	
	# Owner should be the room this enemy belongs to
	room_id = get_owner().room_id
	
	# Get reference to player object
	player_obj = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	_check_aggro()
	
	# Get push vector, is zero if nothing is overlapping
	var push = _pushbox.check_push()
	
	# Apply movement OR knockback, prioritze knockback
	if is_move_state and knockback == Vector2.ZERO:
			_move(delta, push)
			
			# Face player if needed
			if _face_player:
				if global_position.x > player_obj.global_position.x:
					_body_sprite.texture = Texture_Left
					if (_body_sprite.scale.x < 0):
						_body_sprite.scale.x *= -1
				else:
					_body_sprite.texture = Texture_Right
					if (_body_sprite.scale.x > 0):
						_body_sprite.scale.x *= -1
	else:
		# knockback and curr_knockback_strength should be equal/decreasing at same rate
		# Prioritize knockback (if knockback is not zero, enemy should not move)
		knockback = knockback.move_toward(Vector2.ZERO, DECEL * delta)
		curr_knockback_strength = clamp(curr_knockback_strength - (DECEL * delta), 0, 9999)
		knockback = move_and_slide(knockback)

# Called by damaging objects to apply knockback to this enemy
func apply_knockback(knockback_vector, knockback_strength):
	# Only applies knockback if it is greater knockback than enemy's curr knockback
	if knockback_strength > curr_knockback_strength:
		curr_knockback_strength = knockback_strength
		knockback = knockback_vector.normalized() * curr_knockback_strength

# Check for aggro onto player
func _check_aggro():
	if not is_aggro and room_id == player_obj.curr_room_id:
		is_aggro = true
		emit_signal("aggro_started")

# Move functionality for an enemy, should be extended upon
func _move(delta, other):
	pass

# Update health by adding change value to curr_hp
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

# Create flash effect by swapping material on sprites
func _damaged_flash():
	_body_sprite.material = Damaged
	_attack_sprite.material = Damaged
	_flash_timer.start(FLASH_TIME)

# Reset material after timer finishes
func _reset_material():
	_body_sprite.material = null
	_attack_sprite.material = null

# When _health_timer times out, hide health display
func _hide_health():
	_health_display.visible = false

# Can be called by other actions that may stop movement (e.g attack)
# Play idle anim and also stop enemy movement (knockback still applied)
func enter_idle_state():
	is_move_state = false
	_anim.play("idle")

# Can be called by other actions that may stop movement (e.g attack)
# Play activate anim and also stop enemy movement (knockback still applied)
# Mostly for when activating aggro, should transition to move after finish anim
func enter_activate_state():
	is_move_state = false
	_anim.play("activate")

# Can be called by other actions that may stop/start movement (e.g attack)
# Play move anim and also allow enemy movement
func enter_move_state():
	is_move_state = true
	_anim.play("move")

# Can be called by other actions that may stop movement (e.g attack)
# Stop anim and movement
func enter_stop_state():
	_anim.stop()
	is_move_state = false
