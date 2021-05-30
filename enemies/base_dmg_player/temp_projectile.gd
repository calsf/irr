# Projectile that will be destroyed after some given time
extends DamagePlayer
class_name TempProjectile

var Explo = preload("res://enemies/base_dmg_player/ProjectileExplo.tscn")

export var time_alive : int

onready var shadow = $Shadow
onready var timer = $Timer

# Start timer when projectile is created, will be destroyed after time_alive time
func _ready():
	timer.connect("timeout", self, "_on_hit", [null])
	timer.start(time_alive)

# If hits with anything in layer mask, destroys this projectile
func _on_hit(other):
	# Create explo effect, effect's shadow inherits this projectile's shadow pos
	var explo = Explo.instance()
	get_tree().current_scene.add_child(explo)
	explo.get_node("Shadow").position = shadow.position
	explo.global_position = global_position
	
	queue_free()

# Transition from start up to loop animation
func _on_AnimationPlayer_animation_finished(_anim_name):
	_anim.play("loop")