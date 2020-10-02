extends KinematicBody2D

const BASE_SPEED = 32 * 5

var move_speed = BASE_SPEED
var input_vector = Vector2()

onready var _sprite = $Sprite
onready var _anim = $AnimationPlayer
onready var weapon_primary : Weapon = $Wand
onready var weapon_secondary : Weapon = $Dagger
onready var weapon_curr : Weapon = weapon_primary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Movement
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	move_and_slide(input_vector.normalized() * move_speed)
	if (input_vector == Vector2.ZERO):
		_anim.play("Idle")
	else:
		_anim.play("Walk")
		
	# Mouse facing direction
	var mouse_dir = get_global_mouse_position() - global_position
	var rot = rad2deg(atan2(mouse_dir.y, mouse_dir.x))
		
	# Player facing direction to match mouse facing direction
	if (mouse_dir.x < 0):
		if (_sprite.scale.x < 0):
			_sprite.scale.x *= -1
	else:
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
		else:
			weapon_curr = weapon_primary
		weapon_curr.visible = true
