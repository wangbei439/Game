extends Area3D
class_name TeleportPoint

@export var point_id: String = "forest_edge_gate"
@export var display_name: String = "Forest Edge Gate"
@export var quest_event_id: String = "unlock_forest_teleport"
@export var auto_unlock: bool = true

var unlocked: bool = false

func _ready() -> void:
	add_to_group("teleport_point")
	monitoring = true
	body_entered.connect(_on_body_entered)

func unlock() -> void:
	if unlocked:
		return
	unlocked = true
	var world_manager: Node = get_tree().get_first_node_in_group("world_manager")
	if world_manager != null and world_manager.has_method("unlock_teleport"):
		world_manager.call("unlock_teleport", point_id)
	_notify_quest()

func _notify_quest() -> void:
	if quest_event_id.is_empty():
		return
	var quest_manager: Node = get_tree().get_first_node_in_group("quest_manager")
	if quest_manager != null and quest_manager.has_method("register_event"):
		quest_manager.call("register_event", quest_event_id, 1)

func _on_body_entered(body: Node3D) -> void:
	if auto_unlock and (body.name == "Player" or body.is_in_group("player")):
		unlock()
