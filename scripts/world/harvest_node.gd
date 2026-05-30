extends Area3D
class_name HarvestNode

@export var harvest_id: String = "spore_cluster"
@export var material_id: String = "mushroom_spore"
@export var amount: int = 1
@export var quest_event_id: String = "harvest_spores"
@export var cooldown_seconds: float = 8.0
@export var auto_harvest: bool = true

var available: bool = true

func _ready() -> void:
	add_to_group("harvest_node")
	monitoring = true
	body_entered.connect(_on_body_entered)

func harvest() -> bool:
	if not available:
		return false
	available = false
	var world_manager: Node = get_tree().get_first_node_in_group("world_manager")
	if world_manager != null and world_manager.has_method("add_material"):
		world_manager.call("add_material", material_id, amount)
	_notify_quest()
	get_tree().create_timer(cooldown_seconds).timeout.connect(_reset_available)
	return true

func _notify_quest() -> void:
	if quest_event_id.is_empty():
		return
	var quest_manager: Node = get_tree().get_first_node_in_group("quest_manager")
	if quest_manager != null and quest_manager.has_method("register_event"):
		quest_manager.call("register_event", quest_event_id, amount)

func _reset_available() -> void:
	available = true

func _on_body_entered(body: Node3D) -> void:
	if auto_harvest and (body.name == "Player" or body.is_in_group("player")):
		harvest()
