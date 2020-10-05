# Object that deals damage to enemies
# Base class for object that deals damage to enemies
extends Node2D
class_name DamageEnemy

export var _damage_props : Resource
onready var _speed = _damage_props.base_speed
onready var _damage = _damage_props.base_damage
onready var _knockback = _damage_props.knockback
onready var _meter_gain = _damage_props.meter_gain

var dir = Vector2()

func _ready():
	$Hitbox.connect("area_entered", self, "_on_hit")
	$Hitbox.connect("body_entered", self, "_on_hit")

func _process(delta):
	position += (dir * _speed) * delta

# Do something when damage object enters an area2d
# other is the entering area or entering body to this object
func _on_hit(other):
	print("Default on hit")

# Increase player meter when damage object hits an enemy
func _add_meter():
	PlayerMeter.add_meter(_meter_gain)
