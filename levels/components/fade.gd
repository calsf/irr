extends ColorRect

# Number of nodes that should persist in root tree
# Includes autoloaded nodes and the level scene itself
# Should free all objects after (free root_nodes[PERSISTENT_NODES + 1] and onwards)
const PERSISTENT_NODES = 5

signal fade_in_finished
signal fade_out_finished

var _in_transition = false
var _next_scene = ""

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS	# This will never pause
	hide()

# Sets next scene to go to and play fade in animation
func go_to_scene(scene_name):
	if not _in_transition:
		_in_transition = true
		_next_scene = scene_name
		color.a = 0
		show()
		fade_in()

func fade_in():
	$AnimationPlayer.play("FadeIn")

func fade_out():
	$AnimationPlayer.play("FadeOut")

# Remove all nodes in root other than autoloaded nodes and the level scene
# Should be done before reloading/changing scenes
func _remove_root_nodes():
	var root_nodes = get_tree().get_root().get_children()
	for i in range(PERSISTENT_NODES + 1, root_nodes.size()):
		root_nodes[i].queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	match (anim_name):
		"FadeIn":	# Reload current scene if no next scene specified
			if _next_scene == "":
				_remove_root_nodes()
				get_tree().reload_current_scene()
			else:
				_remove_root_nodes()
				get_tree().change_scene(_next_scene)
			
			# Make sure to unpause after loading new scene if was paused previously
			if get_tree().paused:
				get_tree().paused = false
			emit_signal("fade_in_finished")
		"FadeOut": 
			emit_signal("fade_out_finished")
