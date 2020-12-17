extends Control

const DISPLAY_TIME = 3
const METER_RATIO = .32

onready var _meter_timer = $MeterTimer
onready var _fill = $MeterFill
onready var _bg = $MeterBG
onready var _outline = $Outline

var last_meter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	last_meter = PlayerMeter.curr_meter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If meter has changed, reset timer
	if last_meter != PlayerMeter.curr_meter:
		_meter_timer.start(DISPLAY_TIME)
		self.visible = true
		_fill.rect_size.x = PlayerMeter.curr_meter * METER_RATIO
	
	last_meter = PlayerMeter.curr_meter

# Hide meter after timer runs out
func _on_MeterTimer_timeout():
	self.visible = false
