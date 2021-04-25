extends Interactable
class_name Door

export var scene_path = ""

onready var _anim = $AnimationPlayer
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

# Scene sounds
onready var _sounds = $Sounds

var player = null
var entered = false	# To check for right door entered when player_fell signal is fired

func _ready():
	player = get_tree().current_scene.get_node("Player")
	
	# This will trigger all doors to go to scene after player fell anim
	# entered variable will make sure that only the door that was entered will be fired
	player.connect("player_fell", self, "_go_to_scene")
	_anim.connect("animation_finished", self, "_player_fall")

# Stop player and open door
func interact():
	entered = true
	player.stop_player()
	_anim.play("open")
	
	_sounds.play("DoorOpen")

# Play player falling animation after door open animation
func _player_fall(_animation):
	player.player_fall()

# Only go to scene for this door if player entered this door
func _go_to_scene():
	if entered:
		_fade.go_to_scene(scene_path)
