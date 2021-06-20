# Default behaviour for a damage player projectile
# Destroyed upon hitting player or terrain, deals damage to player
extends DamagePlayer
class_name DefaultProjectile

# Destroy automatically in case projectile is stuck alive (i.e reflecting)
const MAX_TIME_ALIVE = 30

var Explo = preload("res://enemies/base_dmg_player/ProjectileExplo.tscn")

onready var shadow = $Shadow
onready var timer = $Timer

# Signal emitted before this projectile gets destroyed
signal destroyed()

func _ready():
	timer.connect("timeout", self, "_destroy")
	timer.start(MAX_TIME_ALIVE)

# If hits with anything in layer mask, destroys this projectile
func _on_hit(other):
	# Don't destroy if hit another enemy (e.g like enemy_reflect)
	if other != null and other.get_owner() != null \
			and other.get_owner().is_in_group("enemies"):
		return
	
	# Create explo effect, effect's shadow inherits this projectile's shadow pos
	var explo = Explo.instance()
	get_tree().current_scene.add_child(explo)
	explo.get_node("Shadow").position = shadow.position
	explo.global_position = global_position
	
	emit_signal("destroyed")
	queue_free()

func _destroy():
		# Create explo effect, effect's shadow inherits this projectile's shadow pos
	var explo = Explo.instance()
	get_tree().current_scene.add_child(explo)
	explo.get_node("Shadow").position = shadow.position
	explo.global_position = global_position
	queue_free()

# Transition from start up to loop animation
func _on_AnimationPlayer_animation_finished(_anim_name):
	_anim.play("loop")
