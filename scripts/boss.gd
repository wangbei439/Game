extends CharacterBody3D

var hp = 300
var max_hp = 300
var speed = 2.0
var chase_speed = 4.0
var detect_range = 12.0
var attack_range = 3.0
var state = "idle"
var phase = 1
var player = null
var attack_cooldown = 0.0
var original_color
var phase_shifted = false

func _ready():
	original_color = $body.mesh.surface_get_material(0).albedo_color

func _physics_process(delta):
	if hp <= 0:
		return
	
	find_player()
	
	# 阶段切换
	if phase == 1 and hp <= max_hp * 0.6 and not phase_shifted:
		enter_phase_2()
	if phase == 2 and hp <= max_hp * 0.3 and not phase_shifted:
		enter_phase_3()
	
	attack_cooldown -= delta
	
	match state:
		"idle":
			velocity.x = 0
			velocity.z = 0
		"chase":
			do_chase(delta)
		"attack":
			do_attack(delta)
	
	move_and_slide()
	update_hp_bar()

func find_player():
	player = get_node_or_null("../Player")
	if player == null:
		return
	var dist = position.distance_to(player.position)
	if dist < attack_range:
		state = "attack"
	elif dist < detect_range:
		state = "chase"
	else:
		state = "idle"

func do_chase(delta):
	if player == null:
		state = "idle"
		return
	var direction = (player.position - position).normalized()
	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed
	velocity.y = 0
	if direction.x != 0:
		$body.scale.x = -1 if direction.x < 0 else 1

func do_attack(delta):
	velocity.x = 0
	velocity.z = 0
	if player == null:
		state = "idle"
		return
	var dist = position.distance_to(player.position)
	if dist > attack_range * 1.5:
		state = "chase"
		return
	
	if attack_cooldown <= 0:
		match phase:
			1:
				phase1_attack()
			2:
				phase2_attack()
			3:
				phase3_attack()

func phase1_attack():
	attack_cooldown = 2.0
	if player.has_method("take_damage"):
		player.take_damage(15)
	flash_body()

func phase2_attack():
	attack_cooldown = 1.5
	if player.has_method("take_damage"):
		player.take_damage(20)
	flash_body()
	# 阶段2：攻击后跳跃
	velocity.y = 6.0

func phase3_attack():
	attack_cooldown = 1.0
	if player.has_method("take_damage"):
		player.take_damage(25)
	flash_body()
	# 阶段3：攻速翻倍，伤害更高

func enter_phase_2():
	phase = 2
	phase_shifted = true
	chase_speed = 6.0
	$body.mesh.surface_get_material(0).albedo_color = Color(1.0, 0.3, 0.0)
	original_color = Color(1.0, 0.3, 0.0)
	# 阶段转换时短暂停顿
	await get_tree().create_timer(0.5).timeout
	phase_shifted = false

func enter_phase_3():
	phase = 3
	phase_shifted = true
	chase_speed = 8.0
	$body.mesh.surface_get_material(0).albedo_color = Color(0.5, 0.0, 0.0)
	original_color = Color(0.5, 0.0, 0.0)
	await get_tree().create_timer(0.5).timeout
	phase_shifted = false

func flash_body():
	$body.mesh.surface_get_material(0).albedo_color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$body.mesh.surface_get_material(0).albedo_color = original_color

func update_hp_bar():
	var ratio = float(hp) / float(max_hp)
	$hp_bar/hp_fill.scale.x = ratio
	$hp_bar/hp_fill.position.x = -(1.0 - ratio) * 1.0

func take_damage(amount):
	hp -= amount
	hp = max(hp, 0)
	show_damage_number(amount)
	flash_body()
	if hp <= 0:
		print("Boss被击败了！")
		drop_loot()
		queue_free()

func show_damage_number(amount):
	var label = $dmg_text
	label.text = str(amount)
	label.visible = true
	label.modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(label, "position:y", 5.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.visible = false
	label.position.y = 3.0

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
