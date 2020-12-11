# Base class for enemies
extends KinematicBody2D
class_name Enemy

const DECEL = 500

export var _enemy_props : Resource
onready var _curr_hp = _enemy_props.max_hp
onready var _move_speed = _enemy_props.move_speed
onready var _health_display = $HealthDisplay
onready var _health_fill = $HealthDisplay/HealthFill
onready var _health_bg = $HealthDisplay/HealthBG
onready var _anim = $AnimationPlayer

var knockback = Vector2.ZERO
var curr_knockback_strength = 0
var _health_ratio = 0

func _ready():
	# Set health amount to health fill ratio
	_health_ratio = _curr_hp / _health_bg.rect_size.x

func _physics_process(delta):
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

# Update health by adding change value to curr_hp
func update_health(change):
	_curr_hp += change
	
	# Update health fill
	_health_fill.rect_size.x += change / _health_ratio
	
	# If health reaches 0 or below, enemy is dead
	if _curr_hp <= 0:
		queue_free()
