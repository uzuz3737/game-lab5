# Adapted from Silver Demon Studios 3D Platformer Starter Kit (MIT).
# Preserves camera-relative movement, double jump, model turn and Idle/Run/Jump/Flip.
extends CharacterBody3D

@export var move_speed: float = 7.0
@export var jump_force: float = 9.0
@export var follow_lerp_factor: float = 8.0
@export var jump_limit: int = 2
@onready var model: Node3D = $Visual
@onready var spring_arm: Node3D = $Gimbal
@onready var camera: Camera3D = $Gimbal/SpringArm3D/Camera3D
var animation: AnimationPlayer
var gravity: float = 22.0
var can_double_jump := false
var enabled := true
var invulnerable := 0.0
var jump_buffer := 0.0
var coyote := 0.0
var flip_time := 0.0
var camera_pitch := -0.40
var start_position := Vector3.ZERO

func _ready() -> void:
	add_to_group("player")
	start_position = global_position
	spring_arm.top_level = true
	spring_arm.global_position = global_position + Vector3.UP * 1.3
	$Gimbal/SpringArm3D.add_excluded_object(get_rid())
	animation = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_remap_animations()
	spring_arm.rotation.x = camera_pitch
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _remap_animations() -> void:
	if not animation:
		return
	var library := AnimationLibrary.new()
	var mappings := {"Idle": "Idle", "Run": "Run", "Flip": "Roll"}
	for destination in mappings:
		for source in animation.get_animation_list():
			if String(source).ends_with("|" + mappings[destination]) or source == mappings[destination]:
				var clip: Animation = animation.get_animation(source).duplicate(true)
				clip.loop_mode = Animation.LOOP_NONE if destination == "Flip" else Animation.LOOP_LINEAR
				library.add_animation(destination, clip)
				break
	# The asset has no jump clip. Build a held airborne pose from its neutral idle.
	if library.has_animation("Idle"):
		var jump: Animation = library.get_animation("Idle").duplicate(true)
		for track in range(jump.get_track_count()):
			while jump.track_get_key_count(track) > 1:
				jump.track_remove_key(track, 1)
		jump.length = 0.8
		jump.loop_mode = Animation.LOOP_LINEAR
		library.add_animation("Jump", jump)
	animation.add_animation_library("courier", library)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and enabled:
		spring_arm.rotation.y -= event.relative.x * 0.003
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, -0.95, -0.16)
		spring_arm.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	invulnerable = maxf(0.0, invulnerable - delta)
	model.visible = invulnerable <= 0.0 or fmod(invulnerable, 0.18) > 0.07
	jump_buffer = maxf(0.0, jump_buffer - delta)
	coyote = 0.12 if is_on_floor() else maxf(0.0, coyote - delta)
	if is_on_floor():
		can_double_jump = true
		flip_time = 0.0
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.13
	if jump_buffer > 0.0:
		if coyote > 0.0:
			perform_jump()
		elif can_double_jump:
			perform_flip_jump()
	velocity.y -= gravity * delta
	get_input(delta)
	move_and_slide()
	player_animations(delta)
	if is_moving():
		var look_direction := Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12.0)
	spring_arm.global_position = spring_arm.global_position.lerp(global_position + Vector3.UP * 1.3, minf(1.0, delta * follow_lerp_factor))
	if global_position.y < -12.0:
		get_tree().current_scene.respawn_player()

func get_input(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	var speed := move_speed * (1.35 if Input.is_action_pressed("sprint") else 1.0)
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * 35.0)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * 35.0)

func perform_jump() -> void:
	velocity.y = jump_force
	jump_buffer = 0.0
	coyote = 0.0
	get_tree().current_scene.play_tone(440.0, 0.11)
	var tween := create_tween()
	tween.tween_property(model, "scale", Vector3(0.9, 1.1, 0.9), 0.08)
	tween.tween_property(model, "scale", Vector3.ONE, 0.12)

func perform_flip_jump() -> void:
	velocity.y = jump_force
	jump_buffer = 0.0
	can_double_jump = false
	flip_time = 0.48
	if animation and animation.has_animation("courier/Flip"):
		animation.play("courier/Flip", 0.08, 2.0)
	get_tree().current_scene.play_tone(660.0, 0.13)

func is_moving() -> bool:
	return Vector2(velocity.x, velocity.z).length() > 0.2

func player_animations(delta: float) -> void:
	flip_time = maxf(0.0, flip_time - delta)
	if not animation or flip_time > 0.0:
		return
	var state := "Jump" if not is_on_floor() else ("Run" if is_moving() else "Idle")
	var clip_name := "courier/" + state
	if animation.has_animation(clip_name) and animation.current_animation != clip_name:
		animation.play(clip_name, 0.15)

func respawn(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	invulnerable = 1.5
	spring_arm.global_position = at + Vector3.UP * 1.3
