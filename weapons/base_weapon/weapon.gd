# Base class for player weapons
extends Node2D
class_name Weapon

onready var _spawn_pos = $Sprite/SpawnPos
onready var _anim = $AnimationPlayer
onready var _sprite = $Sprite

var mouse_dir = Vector2()
var rot = 0
var is_attacking = false

func _ready():
	_sprite.frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Mouse facing direction
	mouse_dir = get_global_mouse_position() - global_position
	rot = rad2deg(atan2(mouse_dir.y, mouse_dir.x))
	
	# Weapon rotation
	_sprite.rotation_degrees = rot + 90
	if rot > -90 and rot < 90:
		if (_sprite.scale.x < 0):
			_sprite.scale.x *= -1
	else:
		if (_sprite.scale.x > 0):
			_sprite.scale.x *= -1
	
	# Weapon z rendering, should always be child of player
	if (mouse_dir.y > 0):
		show_behind_parent = false
	else:
		show_behind_parent = true

# Play normal attack animation
func normal_attack():
	_anim.play("normal_attack")

# Play empowered attack animation
func empowered_attack():
	_anim.play("empowered_attack")

# Default behaviour for a normal ranged attack
# Shoot projectile in direction of mouse
func spawn_range_normal(Projectile):
	var proj = Projectile.instance()
	proj.scale = get_owner().scale
	get_tree().get_root().add_child(proj)
	proj.global_position = _spawn_pos.global_position
	proj.dir = mouse_dir.normalized()

# Default behaviour for a normal melee attack
# Melee attack in direciton of mouse
func spawn_melee_normal(Melee):
	var melee = Melee.instance()
	add_child(melee)
	melee.global_position = _spawn_pos.global_position
	melee.rotation_degrees = rot + 90
