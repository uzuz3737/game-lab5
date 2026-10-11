extends Area3D
var unlocked := false
var elapsed := 0.0
var notice_cooldown := 0.0
func _ready() -> void:
	add_to_group("portals")
	body_entered.connect(_enter)
func _process(delta: float) -> void:
	elapsed += delta
	notice_cooldown = maxf(0, notice_cooldown - delta)
	$Core.rotation.z = sin(elapsed) * 0.05
	$Core.scale = Vector3.ONE * (1.0 + sin(elapsed * 2) * 0.03)
	if unlocked:
		for body in get_overlapping_bodies():
			_enter(body)
func unlock() -> void:
	unlocked = true
	$Core.material_override = load("res://assets/materials/mint.tres")
	$Status.text = "GATE OPEN"
func _enter(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if unlocked:
		get_tree().current_scene.finish_level()
	elif notice_cooldown <= 0:
		notice_cooldown = 2.0
		get_tree().current_scene.show_notice("เก็บคริสตัลให้ครบก่อน ประตูจึงจะเปิด", 2.0)
