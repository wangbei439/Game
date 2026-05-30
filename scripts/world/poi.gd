extends Area3D
class_name POI

@export var poi_id: String = ""
@export var display_name: String = "Point of Interest"
@export var quest_event_id: String = ""
@export var auto_discover: bool = true

var discovered: bool = false

func _ready() -> void:
	add_to_group("poi")
	monitoring = true
	body_entered.connect(_on_body_entered)

func discover() -> void:
	if discovered:
		return
	discovered = true
	var world_manager: Node = get_tree().get_first_node_in_group("world_manager")
	if world_manager != null and world_manager.has_method("discover_poi"):
		world_manager.call("discover_poi", poi_id)
	_notify_quest()

func _notify_quest() -> void:
	if quest_event_id.is_empty():
		return
	var quest_manager: Node = get_tree().get_first_node_in_group("quest_manager")
	if quest_manager != null and quest_manager.has_method("register_event"):
		quest_manager.call("register_event", quest_event_id, 1)

func _on_body_entered(body: Node3D) -> void:
	if not auto_discover:
		return
	if body.name == "Player" or body.is_in_group("player"):
		discover()
