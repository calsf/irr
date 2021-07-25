extends CanvasLayer

var player = null
var room_id = -1

onready var _dialog_start = $DialogContainer/DialogBoxStart
onready var _dialog_killed_monster = $DialogContainer/DialogBoxKilledMonster
onready var _dialog_killed_princess = $DialogContainer/DialogBoxKilledPrincess
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

onready var _princess = get_parent().get_node("Princess")
onready var _monster = get_parent().get_node("Monster")
onready var _self_destruct = get_parent().get_node("SelfDestruct")
onready var _self_destruct_anim = get_parent().get_node("SelfDestruct/AnimationPlayer")
onready var _princess_hurtbox = get_parent().get_node("Princess/Hurtbox/CollisionShape2D")
onready var _monster_hurtbox = get_parent().get_node("Monster/Hurtbox/CollisionShape2D")

onready var _dialog_options = get_node("DialogContainer/DialogBoxKilledMonster/DialogOptions").get_children()

var has_killed = false
var _cursor = load("res://cursor.png")
var _crosshair = load("res://crosshair.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("Player")
	player.connect("entered_room", self, "_on_entry")
	
	# Let player resume action after start dialog is finished
	_dialog_start.connect("dialog_finished", self, "_resume_action")
	
	# After killing princess dialog is finished
	_dialog_killed_princess.connect("dialog_finished", self, "_after_killed_princess_dialog")
	
	# After killing monster dialog is finished
	_dialog_killed_monster.connect("dialog_finished", self, "_after_killed_monster_dialog")
	
	# Change cursor for dialog options
	for option in _dialog_options:
		option.connect("mouse_entered", self, "_on_mouse_enter")
		option.connect("mouse_exited", self, "_on_mouse_exited")
	
	# Owner should be the room this object belongs to
	room_id = get_owner().room_id
	
	# Hurtboxes should be disabled at start
	_princess_hurtbox.disabled = true
	_monster_hurtbox.disabled = true
	
	# Init self destruct
	_self_destruct.scale = Vector2.ZERO
	_self_destruct.visible = false

func _physics_process(delta):
	if not has_killed and (not _princess or not _monster):
		has_killed = true
		
		# Special case of both dying at same time, activate the monster SD
		if not _princess and not _monster:
			_after_killed_princess_dialog()
			return
		
		if not _princess:	# Princess was killed
			_monster_hurtbox.disabled = true
			_show_killed_princess_dialog()
		elif not _monster:	# Monster was killed
			_princess_hurtbox.disabled = true
			_show_killed_monster_dialog()
		
		# Disable player action
		player.stop_player()

# On entry, pause player action, let animations play, then prompt dialog
# After dialog is finished, it should resume player action
func _on_entry(entered_room_id):
	if entered_room_id == room_id:
		player.stop_player()
		
		GlobalSounds.play("BigExplo")
		
		# Wait for end room animations to finish then activate start dialog
		yield(get_tree().create_timer(2), "timeout")
		_dialog_start.activate_dialog()

# Allow player to act again after start animation and dialog is finished
func _resume_action():
	player.can_act = true
	_princess_hurtbox.disabled = false
	_monster_hurtbox.disabled = false

# Dialog after killing princess
func _show_killed_princess_dialog():
	yield(get_tree().create_timer(1), "timeout")
	_dialog_killed_princess.activate_dialog()

# Start self destruct anim after dialog finished
func _after_killed_princess_dialog():
	_self_destruct.visible = true
	_self_destruct_anim.play("sd")

# Kill player during self destruct anim
func kill_player():
	PlayerHealth.lose_health(5)

# Dialog after killing monster
func _show_killed_monster_dialog():
	yield(get_tree().create_timer(1), "timeout")
	_dialog_killed_monster.activate_dialog()

# Save and load level select scene after killed monster dialog finishes
func _after_killed_monster_dialog():
	# Save data
	var save_data = SaveLoadManager.load_data()
	save_data["finished_level0"] = true
	SaveLoadManager.save_data(save_data)
	
	# Wait
	yield(get_tree().create_timer(1), "timeout")
	
	# Load level select scene
	_fade.go_to_scene("res://levels/level_select/LevelSelect.tscn")

# Set to cursor on mouse enter
func _on_mouse_enter():
	Input.set_custom_mouse_cursor(_cursor, 0, Vector2.ZERO)

# Set to crosshair on mouse exit
func _on_mouse_exited():
	Input.set_custom_mouse_cursor(_crosshair, 0, Vector2(12, 12))
