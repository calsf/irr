extends Interactable
class_name PrincessInteractable

onready var _dialog = get_parent().get_node("CanvasLayer/DialogContainer/DialogBoxTalk")

func _ready():
	var save_data = SaveLoadManager.load_data()
	if save_data["level7_completed"]:
		queue_free()

func interact():
	_dialog.activate_dialog()
