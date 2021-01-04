extends CanvasLayer

const HEART_SIZE = 16	# Size of one heart
const METER_RATIO = .46	# Meter amount to filled bar ratio of 1 : 0.46

onready var curr_hearts = $HUD/CurrHearts
onready var lost_hearts = $HUD/LostHearts
onready var meter_fill = $HUD/MeterFill
onready var weapon_primary = $HUD/PrimaryWeapon
onready var weapon_secondary = $HUD/SecondaryWeapon
onready var selected_primary = $HUD/PrimaryWeapon/Selected
onready var selected_secondary = $HUD/SecondaryWeapon/Selected

# Called when the node enters the scene tree for the first time.
func _ready():
	lost_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Remains max
	curr_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Init to max
	meter_fill.visible = false	# Meter should be 0 at start
	
	# Parent must have player_controller.gd
	self.get_parent().connect("primary_selected", self, "_update_selected", [1])
	self.get_parent().connect("secondary_selected", self, "_update_selected", [2])
	self.get_parent().connect("primary_swapped", self, "_update_primary_icon")
	self.get_parent().connect("secondary_swapped", self, "_update_secondary_icon")
	
	PlayerHealth.connect("health_updated", self, "_update_hearts")
	PlayerMeter.connect("meter_updated", self, "_update_meter")

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
func _update_primary_icon(path):
	weapon_primary.texture = load(path)

# Update secondary weapon icon when signal received, signal should send icon path
func _update_secondary_icon(path):
	weapon_secondary.texture = load(path)
