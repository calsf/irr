# Base class for enemies
extends KinematicBody2D
class_name Enemy

const DECEL = 500
const DISPLAY_TIME = 3

export var _enemy_props : Resource
export var _death_path : String
onready var _curr_hp = _enemy_props.max_hp
onready var _move_speed = _enemy_props.move_speed
onready var _pushbox = $Pushbox
onready var _health_display = $HealthDisplay
onready var _health_fill = $HealthDisplay/HealthFill
onready var _health_bg = $HealthDisplay/HealthBG
onready var _health_timer = $HealthDisplayTimer
onready var _anim = $AnimationPlayer

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var curr_knockback_strength = 0
var _health_ratio = 0
var is_move_state = true

# Reference to player should be set by player
var player_obj = null

func _ready():
	# Set health amount to health fill ratio
	_health_ratio = _curr_hp / _health_bg.rect_size.x
	_health_timer.connect("timeout", self, "_hide_health")
	_health_display.visible = false

func _physics_process(delta):
	# Get push vector, is zero if nothing is overlapping
	var push = _pushbox.check_push()
	
	# Apply movement OR knockback, prioritze knockback
	if is_move_state and knockback == Vector2.ZERO:
			_move(delta, push)
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

func _move(delta, other):
	pass

# Update health by adding change value to curr_hp
func update_health(change):
	_curr_hp += change
	
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

# When _health_timer times out, hide health display
func _hide_health():
	_health_display.visible = false

# Should be called by other actions that may stop movement (e.g attack)
# Play idle anim and also stop enemy movement (knockback still applied)
func enter_idle_state():
	is_move_state = false
	_anim.play("idle")

# Should be called by other actions that may stop movement (e.g attack)
# Play activate anim and also stop enemy movement (knockback still applied)
# Mostly for when activating aggro, should transition to move after finish anim
func enter_activate_state():
	is_move_state = false
	_anim.play("activate")

# Should be called by other actions that may stop movement (e.g attack)
# Play move anim and also allow enemy movement
func enter_move_state():
	is_move_state = true
	_anim.play("move")
