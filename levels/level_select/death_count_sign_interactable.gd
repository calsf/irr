extends Interactable
class_name DeathCountSignInteractable

onready var _dialog = get_parent().get_node("CanvasLayer/DialogContainer/DialogBoxSign")

var message = ""

func _ready():
	var save_data = SaveLoadManager.load_data()
	message = [ "Death count: " + str(save_data["death_count"]) ]

func interact():
	_dialog.set_messages(message)
	_dialog.activate_dialog()
