# Projectile acts same as default but is only temporarily destroyed (de-activated)
# Temporarily destroyed upon hitting player or terrain, deals damage to player
extends DamagePlayer
class_name PermaProjectile

var Explo = preload("res://enemies/base_dmg_player/ProjectileExplo.tscn")

onready var shadow = $Shadow
onready var sprite = $Sprite
onready var hitbox_area = $Hitbox/CollisionShape2D
onready var hitbox = $Hitbox
onready var respawn_timer = $RespawnTimer

export var respawn_time = .8	# Time it takes to reactivate the projectile

func _ready():
	respawn_timer.connect("timeout", self, "_reactivate")

# If hits with anything in layer mask, destroys this projectile
func _on_hit(other):
	# Create explo effect, effect's shadow inherits this projectile's shadow pos
	var explo = Explo.instance()
	get_tree().current_scene.add_child(explo)
	explo.get_node("Shadow").position = shadow.position
	explo.global_position = global_position
	
	_deactivate()

# Permanently destroy projectile
func destroy():
	# Create explo effect, effect's shadow inherits this projectile's shadow pos
	var explo = Explo.instance()
	get_tree().current_scene.add_child(explo)
	explo.get_node("Shadow").position = shadow.position
	explo.global_position = global_position
	
	queue_free()

# Reactivates projectile
func _reactivate():
	_anim.play("startup")
	hitbox.monitorable = true	# Reset monitorable back on
	shadow.visible = true
	sprite.visible = true
	hitbox_area.disabled = false

# Deactivates projectile and starts timer to respawn/reactivate it
func _deactivate():
	shadow.visible = false
	sprite.visible = false
	sprite.frame = 0
	_anim.stop()
	hitbox_area.call_deferred("disabled", true)
	respawn_timer.start(respawn_time)
	
	# Toggle monitorable in case projectiles stay overlapping collision area
	hitbox.set_deferred("monitorable", false)
	

# Transition from start up to loop animation
func _on_AnimationPlayer_animation_finished(_anim_name):
	_anim.play("loop")
