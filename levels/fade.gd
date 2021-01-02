extends ColorRect

signal fade_in_finished
signal fade_out_finished

var _in_transition = false
var _next_scene = ""

func _ready():
	hide()

# Sets next scene to go to and play fade in animation
func go_to_scene(scene_name):
	if not _in_transition:
		_in_transition = true
		_next_scene = scene_name
		show()
		fade_in()

func fade_in():
	$AnimationPlayer.play("FadeIn")

func fade_out():
	$AnimationPlayer.play("FadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	match (anim_name):
		"FadeIn":
			get_tree().change_scene(_next_scene)
			emit_signal("fade_in_finished")
		"FadeOut": 
			emit_signal("fade_out_finished")
