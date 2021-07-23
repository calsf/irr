extends CanvasLayer

const SPARE_TIME = 6

const END_SPARED_SCENE_PATH = "res://levels/end_scenes/EndOnKill.tscn"

export var boss_final_path : String
onready var BossFinal = load(boss_final_path)

var player
var baby
var has_killed = false

onready var _dialog_start = $DialogContainer/DialogBoxStart
onready var _dialog_killed = $DialogContainer/DialogBoxKilledBaby
onready var _dialog_spared = $DialogContainer/DialogBoxSpareBaby
onready var _spare_timer = $SpareTimer
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

func _ready():
	player = get_tree().current_scene.get_node("Player")
	baby = get_owner().get_node("Enemies/Baby")
	baby.get_node("Hurtbox/CollisionShape2D").disabled = true
	
	player.connect("has_started", self, "_start_dialog")
	_spare_timer.connect("timeout", self, "_spared_dialog")
	
	_dialog_start.connect("dialog_finished", self, "_after_start_dialog")
	_dialog_killed.connect("dialog_finished", self, "_after_killed_dialog")
	_dialog_spared.connect("dialog_finished", self, "_after_spared_dialog")

func _physics_process(delta):
	# If killed baby, stop spare timer and activate dialog
	if not has_killed and not baby:
		has_killed = true
		_killed_dialog()

# Activate initial start dialog upon finishing player start anim
func _start_dialog():
	_dialog_start.activate_dialog()

# Activate dialog for sparing baby
func _spared_dialog():
	if baby:
		baby.get_node("Hurtbox/CollisionShape2D").disabled = true
		_dialog_spared.activate_dialog()

# Activate dialog for killing baby and stop the spare timer
func _killed_dialog():
	yield(get_tree().create_timer(1), "timeout")
	_spare_timer.stop()
	_dialog_killed.activate_dialog()

# After start dialog, activate baby hurtbox and start spare timer
func _after_start_dialog():
	baby.get_node("Hurtbox/CollisionShape2D").disabled = false
	_spare_timer.start(SPARE_TIME)

func _after_killed_dialog():
	var boss = BossFinal.instance()
	get_owner().get_node("Enemies").add_child(boss)
	boss.global_position = Vector2.ZERO

func _after_spared_dialog():
	# Save as level completed
	var save_data = SaveLoadManager.load_data()
	save_data["level7_completed"] = true
	SaveLoadManager.save_data(save_data)
	
	yield(get_tree().create_timer(2), "timeout")
	_fade.go_to_scene(END_SPARED_SCENE_PATH)
