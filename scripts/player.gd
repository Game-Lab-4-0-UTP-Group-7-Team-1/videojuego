class_name Player  extends CharacterBody2D
signal attack_finished
@onready var anim = $AnimatedSprite2D
@onready var health_component: HealthComponent = $Components/HealthComponent


const SPEED = 120
var attack_damage := 10
const JUMP_FORCE = -350
const GRAVITY = 900
var is_attacking = false
var direction := 0.0

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	health_component.death.connect(on_death)
	add_to_group("player")

	

func on_death():
	print("game over")
	get_tree().paused = true
	
func _physics_process(delta):
	direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0  # bloqueamos movimiento si está atacando

	# Flip horizontal
	if direction != 0:
		anim.flip_h = direction < 0

	# Salto permitido incluso si ataca
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
		if not is_attacking:
			play_animation("jump")

	# Ataque aéreo o terrestre
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		play_animation("attack")

		# calculamos duración del ataque manualmente
		var frames = anim.sprite_frames.get_frame_count("attack")
		var speed = anim.sprite_frames.get_animation_speed("attack")
		var attack_duration = frames / speed

		await get_tree().create_timer(attack_duration).timeout
		is_attacking = false
		return

	# Animaciones automáticas si no está atacando
	if not is_attacking:
		if not is_on_floor():
			play_animation("jump")
		elif direction != 0:
			play_animation("run")
		else:
			play_animation("idle")

	# Gravedad
	velocity.y += GRAVITY * delta
	move_and_slide()

func play_animation(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_animation_finished():
	if anim.animation == "attack":
		is_attacking = false
		attack_finished.emit()

#El enemigo esta en la zona de ataque
func _on_area_attack_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.in_attack_player_range = true

#El enemigo no esta en la zona de ataque
func _on_area_attack_body_exited(body: Node2D) -> void:
	if body is Enemy:
		body.in_attack_player_range = false
