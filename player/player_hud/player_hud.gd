extends Node

const HEART_SIZE = 16	# Size of one heart
const METER_RATIO = .46	# Meter amount to filled bar ratio of 1 : 0.46

onready var curr_hearts = $HUD/CurrHearts
onready var lost_hearts = $HUD/LostHearts
onready var meter_fill = $HUD/MeterFill
onready var weapon_primary = $HUD/PrimaryWeapon
onready var weapon_secondary = $HUD/SecondaryWeapon
onready var selected_primary = $HUD/PrimaryWeapon/Selected
onready var selected_secondary = $HUD/SecondaryWeapon/Selected
onready var info_primary = $PrimaryInfo
onready var info_secondary = $SecondaryInfo

onready var player = get_tree().current_scene.get_node("Player")
var _cursor = load("res://cursor.png")
var _crosshair = load("res://crosshair.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	lost_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Remains max
	curr_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Init to max
	meter_fill.visible = false	# Meter should be 0 at start
	
	# Connect to player_controller.gd to update hud icons
	player.connect("primary_selected", self, "_update_selected", [1])
	player.connect("secondary_selected", self, "_update_selected", [2])
	player.connect("primary_swapped", self, "_update_primary_icon")
	player.connect("secondary_swapped", self, "_update_secondary_icon")
	
	PlayerHealth.connect("health_updated", self, "_update_hearts")
	PlayerMeter.connect("meter_updated", self, "_update_meter")
	
	# Show/hide weapon info on mouse enter and exit
	weapon_primary.connect("mouse_entered", self, "_show_primary_info")
	weapon_secondary.connect("mouse_entered", self, "_show_secondary_info")
	weapon_primary.connect("mouse_exited", self, "_hide_primary_info")
	weapon_secondary.connect("mouse_exited", self, "_hide_secondary_info")
	
	# Hide info on start
	_hide_primary_info()
	_hide_secondary_info()
	

# Update curr hearts when health_updated signal is emitted by PlayerHealth
func _update_hearts():
	if PlayerHealth.curr_hp <= 0:
		curr_hearts.visible = false
	else:
		curr_hearts.visible = true
		curr_hearts.rect_size.x = PlayerHealth.curr_hp * HEART_SIZE

# Update meter bar when meter_updated signal is emitted by PlayerMeter
func _update_meter():
	if PlayerMeter.curr_meter > 0:
		meter_fill.visible = true
		meter_fill.rect_size.x = PlayerMeter.curr_meter * METER_RATIO
	else:
		meter_fill.visible = false

# Highlight selected weapon, 1 = primary selected, 2 = secondary selected
func _update_selected(selected):
	if selected == 1:
		selected_primary.visible = true
		selected_secondary.visible = false
	elif selected == 2:
		selected_primary.visible = false
		selected_secondary.visible = true

# Update primary weapon icon when signal received, signal should send icon path
# Also update primary weapon info
func _update_primary_icon(path):
	info_primary.update_info_primary()
	weapon_primary.texture = load(path)

# Update secondary weapon icon when signal received, signal should send icon path
# Also update secondary weapon info
func _update_secondary_icon(path):
	info_secondary.update_info_secondary()
	weapon_secondary.texture = load(path)

# Show primary weap info, resizes before showing
func _show_primary_info():
	if "Empty" in player.weapon_primary.weapon_props.weapon_name:
		return
	
	info_primary.resize()
	info_primary.visible = true
	Input.set_custom_mouse_cursor(_cursor, 0, Vector2.ZERO)

# Hide primary weap info
func _hide_primary_info():
	info_primary.visible = false
	Input.set_custom_mouse_cursor(_crosshair, 0, Vector2(12, 12))

# Show secondary weap info, resizes before showing
func _show_secondary_info():
	if "Empty" in player.weapon_secondary.weapon_props.weapon_name:
		return
		
	info_secondary.resize()
	info_secondary.visible = true
	Input.set_custom_mouse_cursor(_cursor, 0, Vector2.ZERO)

# Hide secondary weap info
func _hide_secondary_info():
	info_secondary.visible = false
	Input.set_custom_mouse_cursor(_crosshair, 0, Vector2(12, 12))
	
