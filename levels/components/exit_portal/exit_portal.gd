extends Interactable
class_name ExitPortal

onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")
onready var _anim = $AnimationPlayer

var level_select = "res://levels/level_select/LevelSelect.tscn"
var player_obj = null
var level_completed = ""	# Should be set by OnBossKill when exit portal is spawned

func _ready():
	# Get reference to player object
	player_obj = get_tree().current_scene.get_node("Player")

# Once interacted on, save level as completed and go back to level select
func interact():
	var save_data = SaveLoadManager.load_data()
	save_data[level_completed] = true
	SaveLoadManager.save_data(save_data)
	
	player_obj.queue_free()
	_fade.go_to_scene(level_select)

# Enter idle anim
func enter_idle():
	_anim.play("idle")
