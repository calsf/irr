extends DamagePlayer
class_name SplitProjectile

var Explo = preload("res://enemies/base_dmg_player/ProjectileExplo.tscn")

export var split_time : float
export var split_dir : Array
export var proj_path : String

onready var DamageObject = load(proj_path)
onready var shadow = $Shadow
onready var timer = $Timer

func _ready():
	timer.connect("timeout", self, "_split")
	timer.start(split_time)

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

func _split():
	for dir in split_dir:
		var obj = DamageObject.instance()
		get_tree().get_root().add_child(obj)
		obj.global_position = global_position
		obj.dir = dir.normalized()
	
	_on_hit(null)
