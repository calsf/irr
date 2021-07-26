extends Interactable
class_name DeathCountSignInteractable

onready var _dialog = get_parent().get_node("CanvasLayer/DialogContainer/DialogBoxSign")

var message = ""

func _ready():
	var save_data = SaveLoadManager.load_data()
	if save_data["death_count"] == 1:
		message = [ "You have died " + str(save_data["death_count"]) + " time." ]
	else:
		message = [ "You have died " + str(save_data["death_count"]) + " times." ]

func interact():
	_dialog.set_messages(message)
	_dialog.activate_dialog()
