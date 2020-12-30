extends Enemy
class_name ActivateOnEnter

func _ready():
	# Enter activate state/play activate anim upon aggro
	connect("aggro_started", self, "enter_activate_state")
