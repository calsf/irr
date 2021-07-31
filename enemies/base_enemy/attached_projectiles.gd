# For parent node that contains all projectiles attached to an enemy
# Will re-parent the projectiles to child of root for proper YSorting
extends YSort

var _enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	_enemy = get_parent()
	_enemy.call_deferred("remove_child", self)
	get_tree().get_root().call_deferred("add_child", self)
	self.set_owner(get_tree().get_root())
	
	# Wait one frame to avoid projectiles flashing at start before they're moved
	yield(VisualServer, "frame_pre_draw")
	visible = true

# Always follow position of original parent enemy
func _physics_process(delta):
	# If enemy becomes null, destroy all projectiles and self
	if not is_instance_valid(_enemy):
		for p in get_children():
			p.destroy()
		queue_free()
	else:
		global_position = _enemy.global_position
