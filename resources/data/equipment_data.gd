class_name EquipmentData
extends Resource

enum Slot { WEAPON, HEAD, BODY, HAND, FOOT, ACCESSORY }
enum Quality { WHITE, GREEN, BLUE, PURPLE, ORANGE }

@export var name: String = ""
@export var slot: Slot = Slot.WEAPON
@export var quality: Quality = Quality.WHITE
@export var attack: int = 0
@export var defense: int = 0
@export var hp_bonus: int = 0
@export var speed_bonus: float = 0.0
