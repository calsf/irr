# Base class for an non weapon pickup interactable
extends Node2D
class_name Interactable

onready var _interact_area = $InteractArea
onready var _interact_label = $InteractLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show label/hide label when entering/exiting interact area
	_interact_area.connect("area_entered", self, "_show_label")
	_interact_area.connect("area_exited", self, "_hide_label")
	_interact_label.visible = false

func _show_label(_area):
	if _area.get_owner() != null and not _area.get_owner().is_in_group("enemies"):
		_interact_label.visible = true

func _hide_label(_area):
	if _area.get_owner() != null and not _area.get_owner().is_in_group("enemies"):
		_interact_label.visible = false

func interact():
	pass
