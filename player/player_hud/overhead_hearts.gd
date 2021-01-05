extends Control

const DISPLAY_TIME = 3
const HEART_SIZE = 12	# Size of one heart

onready var _curr_hearts = $CurrHearts
onready var _lost_hearts = $LostHearts
onready var _hearts_timer = $HeartsTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	_lost_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Remains max
	_curr_hearts.rect_size.x = PlayerHealth.MAX_HP * HEART_SIZE	# Init to max
	self.visible = false
	
	PlayerHealth.connect("health_updated", self, "_show_hearts")
	_hearts_timer.connect("timeout", self, "_hide_hearts")

# Reset hearts timer whenever health gets updated
func _show_hearts():
	_hearts_timer.start(DISPLAY_TIME)
	self.visible = true
		
	if PlayerHealth.curr_hp <= 0:
		_curr_hearts.visible = false
	else:
		_curr_hearts.visible = true
		_curr_hearts.rect_size.x = PlayerHealth.curr_hp * HEART_SIZE

# Hide hearts after timer runs out
func _hide_hearts():
	self.visible = false
