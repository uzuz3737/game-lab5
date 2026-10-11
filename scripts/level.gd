extends Node3D
@export var level_number := 1
@export var level_title := "MOSS GARDENS"
@export var total_crystals := 8
var collected := 0
var elapsed := 0.0
var falls := 0
var checkpoint := Vector3(0, 1, 2)
var changing := false
var won := false
var hud: CanvasLayer
var sound: AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	checkpoint = player.global_position
	hud = load("res://scripts/hud.gd").new()
	add_child(hud)
	sound = AudioStreamPlayer.new()
	sound.volume_db = -16.0
	add_child(sound)
	show_notice("เก็บคริสตัลครบ %d ชิ้น แล้วเข้าประตูที่ปลายทาง" % total_crystals, 5.0)
	if OS.get_cmdline_user_args().has("--capture"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	if not get_tree().paused and not changing:
		elapsed += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not won:
		if get_tree().paused:
			resume_game()
		else:
			get_tree().paused = true
			hud.show_overlay("พักการเดินทาง", "คริสตัลและจุดเซฟจะยังอยู่\nพร้อมแล้วไปต่อได้เลย")
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("restart") and not changing:
		get_tree().paused = false
		get_tree().reload_current_scene()

func collect_crystal() -> void:
	collected += 1
	play_tone(880.0 + collected * 60.0, 0.14)
	if collected == total_crystals:
		for gate in get_tree().get_nodes_in_group("portals"):
			gate.unlock()
		show_notice("คริสตัลครบแล้ว! ประตูเปิด ไปที่ประตูได้เลย", 4.0)
	hud.update_stats()

func respawn_player() -> void:
	if changing or player.invulnerable > 0:
		return
	falls += 1
	elapsed += 5.0
	player.respawn(checkpoint)
	play_tone(170.0, 0.2)
	show_notice("กลับจุดเซฟแล้ว  +5 วินาที  •  คริสตัลยังอยู่ครบ", 2.4)

func set_checkpoint(at: Vector3) -> void:
	checkpoint = at
	play_tone(740.0, 0.18)
	show_notice("บันทึกจุดเซฟแล้ว", 2.5)

func show_notice(text: String, duration := 3.0) -> void:
	if hud:
		hud.message(text, duration)

func finish_level() -> void:
	if changing or collected < total_crystals:
		return
	changing = true
	player.enabled = false
	play_tone(1100.0, 0.3)
	if level_number == 1:
		show_notice("ผ่านด่านสวนโบราณ! ไปโรงงานพลังงานกัน", 1.0)
		await get_tree().create_timer(0.7).timeout
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	else:
		won = true
		get_tree().paused = true
		hud.show_overlay("ส่งพลังงานสำเร็จ!", "ผ่านครบ 2 ด่าน\nเวลาด่านนี้ %02d:%02d  •  พลาด %d ครั้ง" % [int(elapsed / 60.0), int(elapsed) % 60, falls], true)

func resume_game() -> void:
	get_tree().paused = false
	hud.hide_overlay()
func restart_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
func go_to_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func play_tone(frequency: float, duration: float) -> void:
	if not sound:
		return
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var data := PackedByteArray()
	for sample in range(int(duration * 22050)):
		var envelope := (1.0 - float(sample) / (duration * 22050)) * minf(1.0, sample / 100.0)
		var value := int(sin(TAU * frequency * sample / 22050.0) * envelope * 18000)
		data.append(value & 255)
		data.append((value >> 8) & 255)
	stream.data = data
	sound.stream = stream
	sound.play()
