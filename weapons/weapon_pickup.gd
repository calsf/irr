extends Node2D
class_name WeaponPickup

export var weapon_props : Resource

# weapon_id is used to refer to weapon in Player's Weapons
onready var weapon_id = weapon_props.weapon_id
onready var interact_area = $InteractArea
onready var info_display = $InfoDisplay
onready var display_bg = $DisplayBG

func _ready():
	info_display.get_node("WeaponName").text = weapon_props.weapon_name
	info_display.get_node("WeaponNormal").text = weapon_props.normal_desc
	info_display.get_node("WeaponEmpowered").text = weapon_props.empow_desc
	
	interact_area.connect("area_entered", self, "_show_info")
	interact_area.connect("area_exited", self, "_hide_info")
	
func _show_info(area):
	info_display.visible = true
	display_bg.visible = true

func _hide_info(area):
	info_display.visible = false
	display_bg.visible = false
