extends Control

const DISPLAY_TIME = 3
const METER_RATIO = .32

onready var _meter_timer = $MeterTimer
onready var _fill = $MeterFill
onready var _bg = $MeterBG
onready var _outline = $Outline

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	PlayerMeter.connect("meter_updated", self, "_show_meter")
	_meter_timer.connect("timeout", self, "_hide_meter")

# Reset meter timer whenever meter gets updated
func _show_meter():
	_meter_timer.start(DISPLAY_TIME)
	self.visible = true
	_fill.rect_size.x = PlayerMeter.curr_meter * METER_RATIO

# Hide meter after timer runs out
func _hide_meter():
	self.visible = false
