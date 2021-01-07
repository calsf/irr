extends Interactable
class_name WarningSignInteractable

onready var _dialog = get_parent().get_node("CanvasLayer/DialogContainer/DialogBoxSign")

func interact():
	_dialog.activate_dialog()
