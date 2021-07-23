extends Node

const DELAY = 2	# Delay before showing death screen

# Default empty to reload current scene
export var _reload_scene = ""

onready var _death_screen = get_tree().current_scene.get_node("CanvasLayer/DeathScreen")
onready var _death_screen_anim = get_tree().current_scene.get_node("CanvasLayer/DeathScreen/AnimationPlayer")
onready var _revive_btn = get_tree().current_scene.get_node("CanvasLayer/DeathScreen/ReviveButton")
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

var reviving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerHealth.connect("player_died", self, "_show_death_screen")
	_revive_btn.connect("pressed", self, "_revive")

# Show death screen after a delay
func _show_death_screen():
	yield(get_tree().create_timer(DELAY), "timeout")
	_death_screen.visible = true
	_death_screen_anim.play("FadeIn")

# Revive player, resetting values
func _revive():
	if not reviving:
		GlobalSounds.play("ButtonPressed")
		reviving = true
		PlayerHealth.revive()
		PlayerMeter.reset()
		_fade.go_to_scene(_reload_scene)	# Reload current scene
