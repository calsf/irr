extends CanvasLayer


onready var meter_label = $HUD/Meter
onready var health_label = $HUD/Health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	meter_label.text = String(PlayerMeter.curr_meter)
	health_label.text = String(PlayerHealth.curr_hp)
