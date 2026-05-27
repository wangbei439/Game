extends CharacterBody3D

var hp = 100
var original_color
var speed = 3.0
var chase_speed = 5.0
var detect_range = 8.0
var attack_range = 3.0
var state = "patrol"
var patrol_target = Vector3.ZERO
var patrol_center = Vector3.ZERO
var patrol_radius = 5.0
var player = null

func _ready():
	original_color = $body.mesh.surface_get_material(0).albedo_color
	patrol_center = position
	pick_new_patrol_target()

func _physics_process(delta):
	if hp <= 0:
		return
	
	find_player()
	
	match state:
		"patrol":
			do_patrol(delta)
		"chase":
			do_chase(delta)
		"attack":
			do_attack_state(delta)
	
	move_and_slide()

func find_player():
	player = get_node_or_null("../Player")
	if player == null:
		return
	var dist = position.distance_to(player.position)
	if dist < attack_range:
		state = "attack"
	elif dist < detect_range:
		state = "chase"
	elif dist > detect_range * 1.5 and state != "patrol":
		state = "patrol"
		pick_new_patrol_target()

func do_patrol(delta):
	if position.distance_to(patrol_target) < 1.0:
		pick_new_patrol_target()
		await get_tree().create_timer(1.0).timeout
		return
	var direction = (patrol_target - position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = 0
	face_direction(direction)

func do_chase(delta):
	if player == null:
		state = "patrol"
		return
	var dist = position.distance_to(player.position)
	if dist < attack_range:
		state = "attack"
		return
	var direction = (player.position - position).normalized()
	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed
	velocity.y = 0
	face_direction(direction)

var attack_cooldown = 0.0

func do_attack_state(delta):
	attack_cooldown -= delta
	if player == null:
		state = "patrol"
		return
	var dist = position.distance_to(player.position)
	if dist > attack_range * 1.5:
		state = "chase"
		return
	velocity.x = 0
	velocity.z = 0
	if attack_cooldown <= 0:
		attack_cooldown = 1.5
		if player.has_method("take_damage"):
			player.take_damage(10)
			print("Dummy攻击了玩家！")

func pick_new_patrol_target():
	var angle = randf() * PI * 2
	patrol_target = patrol_center + Vector3(cos(angle), 0, sin(angle)) * patrol_radius

func face_direction(dir):
	if dir.x != 0:
		$body.scale.x = -1 if dir.x < 0 else 1

func take_damage(amount):
	hp -= amount
	show_damage_number(amount)
	$body.mesh.surface_get_material(0).albedo_color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$body.mesh.surface_get_material(0).albedo_color = original_color
	# 被打后立刻追击玩家
	state = "chase"
	if hp <= 0:
		drop_loot()
		queue_free()

func show_damage_number(amount):
	var label = $dmg_text
	label.text = str(amount)
	label.visible = true
	label.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(label, "position:y", 4.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.visible = false
	label.position.y = 2.0

func drop_loot():
	var loot_scene = load("res://loot_item.tscn")
	var loot = loot_scene.instantiate()
	get_parent().add_child(loot)
	loot.position = position + Vector3(0, 0.5, 0)
	loot.setup(pick_random_item())

func pick_random_item():
	var items = [
		load("res://resources/data/iron_sword.tres"),
		load("res://resources/data/copper_bow.tres"),
		load("res://resources/data/leather_cap.tres"),
		load("res://resources/data/leather_armor.tres"),
	]
	return items[randi() % items.size()]
