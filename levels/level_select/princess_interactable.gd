extends Interactable
class_name PrincessInteractable

onready var _dialog = get_parent().get_node("CanvasLayer/DialogContainer/DialogBoxTalk")

func interact():
	_dialog.activate_dialog()
