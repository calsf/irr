extends Node2D
class_name DamagePlayer

export var _damage_props : Resource

onready var _speed = _damage_props.base_speed
onready var _anim = $AnimationPlayer

var speed_multiplier = 1 # Multiplier should be 1 by default
var dir = Vector2()

func _ready():
	$Hitbox.connect("area_entered", self, "_on_hit")
	$Hitbox.connect("body_entered", self, "_on_hit")

func _process(delta):
	_move(delta)
	
# Do something when damage object enters an area2d
# other is the entering area or entering body to this object
func _on_hit(other):
	print("Default on hit")

func _move(delta):
	position += (dir * (_speed * speed_multiplier)) * delta
