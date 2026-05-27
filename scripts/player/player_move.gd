extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 4.5

var stats = PlayerStats.new()
var is_attacking = false
var attack_timer = 0.0
var is_dodging = false
var dodge_timer = 0.0
var dodge_duration = 0.4
var dodge_speed = 15.0
var dodge_direction = Vector3.ZERO
var dodge_cooldown = 0.0

func _ready():
	var sword = load("res://resources/data/iron_sword.tres")
	stats.equip_item(sword)
	var cap = load("res://resources/data/leather_cap.tres")
	stats.add_item(cap)
	var armor = load("res://resources/data/leather_armor.tres")
	stats.add_item(armor)
	var bow = load("res://resources/data/copper_bow.tres")
	stats.add_item(bow)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 闪避
	if dodge_cooldown > 0:
		dodge_cooldown -= delta
	if Input.is_key_pressed(KEY_K) and not is_dodging and not is_attacking and dodge_cooldown <= 0 and is_on_floor():
		is_dodging = true
		dodge_timer = dodge_duration
		dodge_cooldown = 1.0
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir != Vector2.ZERO:
			dodge_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		else:
			dodge_direction = -transform.basis.z.normalized()

	if is_dodging:
		dodge_timer -= delta
		velocity.x = dodge_direction.x * dodge_speed
		velocity.z = dodge_direction.z * dodge_speed
		if dodge_timer <= 0:
			is_dodging = false
		move_and_slide()
		update_hp_bar()
		return

	# 移动
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 攻击
	if Input.is_key_pressed(KEY_J) and not is_attacking and not is_dodging:
		is_attacking = true
		attack_timer = 0.3
		$sprite.modulate = Color(2.0, 2.0, 2.0)
		$sprite.scale = Vector3(1.3, 1.3, 1.0)
		_do_attack()

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			$sprite.modulate = Color.WHITE
			$sprite.scale = Vector3(1.0, 1.0, 1.0)

	move_and_slide()

	if velocity.x != 0:
		$sprite.scale.x = -1 if velocity.x < 0 else 1

	update_hp_bar()

func _do_attack():
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bodies = $hitbox.get_overlapping_bodies()
	for body in bodies:
		if body != self and body.has_method("take_damage"):
			body.take_damage(stats.get_attack())

func take_damage(amount):
	var dmg = stats.take_damage(amount, is_dodging)
	if dmg > 0:
		print("玩家受伤! 伤害: ", dmg, " 剩余HP: ", stats.hp)
	if stats.is_dead():
		print("玩家阵亡！")
		position = Vector3(0, 1, 0)
		stats.respawn()

func update_hp_bar():
	var ratio = float(stats.hp) / float(stats.max_hp)
	$hp_bar/hp_fill.scale.x = ratio
	$hp_bar/hp_fill.position.x = -(1.0 - ratio) * 0.6
