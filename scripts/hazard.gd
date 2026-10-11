extends Area3D
@export_enum("spikes", "saw", "laser") var kind := "spikes"
@export var travel := Vector3.ZERO
@export var period := 3.5
var origin := Vector3.ZERO
var elapsed := 0.0
var active := true

func _ready() -> void:
	add_to_group("hazards")
	origin = position
	body_entered.connect(_hit)

func _physics_process(delta: float) -> void:
	elapsed += delta
	if kind == "saw":
		position = origin + travel * sin(elapsed * TAU / period)
		$Visual.rotation.z += delta * 5.0
	elif kind == "laser":
		active = fmod(elapsed, period) < period * 0.55
		$Visual.visible = active
	if active:
		for body in get_overlapping_bodies():
			_hit(body)

func _hit(body: Node3D) -> void:
	if active and body.is_in_group("player") and body.invulnerable <= 0.0:
		get_tree().current_scene.respawn_player()
