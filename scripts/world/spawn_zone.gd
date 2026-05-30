extends Area3D
class_name SpawnZone

@export var enemy_scene: PackedScene
@export var max_active: int = 3
@export var spawn_interval_seconds: float = 6.0
@export var spawn_radius: float = 3.0
@export var quest_event_id_on_clear: String = "defeat_forest_creatures"
@export var auto_start: bool = true

var active_enemies: Array[Node] = []
var spawn_timer: Timer

func _ready() -> void:
	add_to_group("spawn_zone")
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval_seconds
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	if auto_start:
		call_deferred("_start_spawning")

func _start_spawning() -> void:
	spawn_timer.start()
	_spawn_until_full()

func _on_spawn_timer_timeout() -> void:
	_prune_dead_enemies()
	_spawn_until_full()

func _spawn_until_full() -> void:
	if enemy_scene == null:
		return
	while active_enemies.size() < max_active:
		spawn_enemy()

func spawn_enemy() -> Node:
	if enemy_scene == null:
		return null
	var enemy: Node = enemy_scene.instantiate()
	if enemy is Node3D:
		var offset := Vector3(randf_range(-spawn_radius, spawn_radius), 0.0, randf_range(-spawn_radius, spawn_radius))
		(enemy as Node3D).position = position + offset
	get_parent().add_child(enemy)
	active_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))
	return enemy

func _on_enemy_tree_exited(enemy: Node) -> void:
	active_enemies.erase(enemy)
	_notify_quest(1)

func _notify_quest(amount: int) -> void:
	if quest_event_id_on_clear.is_empty():
		return
	var quest_manager: Node = get_tree().get_first_node_in_group("quest_manager")
	if quest_manager != null and quest_manager.has_method("register_event"):
		quest_manager.call("register_event", quest_event_id_on_clear, amount)

func _prune_dead_enemies() -> void:
	for index in range(active_enemies.size() - 1, -1, -1):
		if not is_instance_valid(active_enemies[index]):
			active_enemies.remove_at(index)
