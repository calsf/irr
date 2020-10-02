# Object that deals damage to enemies
# Base class for object that deals damage to enemies
extends Node2D
class_name DamageEnemy

export var damage_props : Resource
onready var speed = damage_props.base_speed
onready var damage = damage_props.base_damage
onready var knockback = damage_props.knockback

var dir = Vector2()

func _ready():
	$Hitbox.connect("area_entered", self, "_on_hit")
	$Hitbox.connect("body_entered", self, "_on_hit")

func _physics_process(delta):
	position += (dir * speed) * delta

# Do something when damage object enters an area2d
# other is the entering area or entering body to this object
func _on_hit(other):
	print("Default on hit")

# Destroy this object
func destroy():
	queue_free()
