# Base class for player weapons
extends Node2D
class_name Weapon

export var weapon_props : Resource
onready var _spawn_pos = $Sprite/SpawnPos
onready var _anim = $AnimationPlayer
onready var _sprite = $Sprite

var _mouse_dir = Vector2()
var _rot = 0
var _is_attacking = false

func _ready():
	_sprite.frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Mouse facing direction
	_mouse_dir = get_global_mouse_position() - global_position
	_rot = rad2deg(atan2(_mouse_dir.y, _mouse_dir.x))
	
	# Weapon rotation
	_sprite.rotation_degrees = _rot + 90
	if _rot > -90 and _rot < 90:
		if (_sprite.scale.x < 0):
			_sprite.scale.x *= -1
	else:
		if (_sprite.scale.x > 0):
			_sprite.scale.x *= -1
	
	# Weapon z rendering, should always be child of player
	# Need to set parent, all weapons are children of a Weapons node in Player
	if _mouse_dir.y > 0:
		get_parent().show_behind_parent = false
	else:
		get_parent().show_behind_parent = true

# Play normal attack animation
func normal_attack():
	_anim.play("normal_attack")

# Play empowered attack animation
func empowered_attack():
	# Only trigger attack if enough meter and not already in middle of emp attack
	if (PlayerMeter.curr_meter >= weapon_props.empow_cost and \
	(not _anim.is_playing() or _anim.assigned_animation != "empowered_attack")):
		PlayerMeter.lose_meter(weapon_props.empow_cost)
		_anim.play("empowered_attack")

# Default behaviour for a basic ranged attack
# Shoot projectile in direction of mouse
func spawn_range_basic(Projectile):
	var proj = Projectile.instance()
	proj.scale = get_owner().scale
	get_tree().get_root().add_child(proj)
	proj.global_position = _spawn_pos.global_position
	proj.dir = _mouse_dir.normalized()

# Default behaviour for a basic melee attack
# Melee attack in direciton of mouse
func spawn_melee_basic(Melee):
	var melee = Melee.instance()
	add_child(melee)
	melee.global_position = _spawn_pos.global_position
	melee.rotation_degrees = _rot + 90
