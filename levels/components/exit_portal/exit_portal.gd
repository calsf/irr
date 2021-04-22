extends Interactable
class_name ExitPortal

onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")
onready var _anim = $AnimationPlayer

var level_select = "res://levels/level_select/LevelSelect.tscn"
var player_obj = null

func _ready():
	# Get reference to player object
	player_obj = get_tree().current_scene.get_node("Player")

func interact():
	player_obj.queue_free()
	_fade.go_to_scene(level_select)

# Enter idle anim
func enter_idle():
	_anim.play("idle")
