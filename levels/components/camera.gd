extends Camera2D

const PAUSE_DIST = 20
const UNPAUSE_DIST = 18

# If camera is what triggered pause
var cam_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS	# Camera will never pause

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pause while camera moving, unpause within certain distance and if camera is what initially paused game
	if not get_tree().paused and int(get_camera_screen_center().distance_to(get_camera_position())) > PAUSE_DIST:
		cam_paused = true	# Camera triggered pause
		get_tree().paused = true
	elif cam_paused and get_tree().paused and int(get_camera_screen_center().distance_to(get_camera_position())) < UNPAUSE_DIST:
		get_tree().paused = false
		cam_paused = false
