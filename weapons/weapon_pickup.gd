extends Node2D
class_name WeaponPickup

export var _weapon_props : Resource

# weapon_id is used to refer to weapon in Player's Weapons
onready var weapon_id = _weapon_props.weapon_id
onready var _interact_area = $InteractArea
onready var _info_display = $InfoDisplay
onready var _display_bg = $DisplayBG

func _ready():
	_info_display.get_node("WeaponName").text = _weapon_props.weapon_name
	_info_display.get_node("WeaponNormal").text = _weapon_props.normal_desc
	_info_display.get_node("WeaponEmpowered").text = _weapon_props.empow_desc
	
	_interact_area.connect("area_entered", self, "_show_info")
	_interact_area.connect("area_exited", self, "_hide_info")
	
func _show_info(area):
	_info_display.visible = true
	_display_bg.visible = true

func _hide_info(area):
	_info_display.visible = false
	_display_bg.visible = false
