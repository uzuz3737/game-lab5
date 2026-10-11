extends Area3D
var origin_y := 0.0
var time := 0.0
var taken := false

func _ready() -> void:
	add_to_group("crystals")
	origin_y = position.y
	time = position.x * 0.4 + position.z
	body_entered.connect(_collect)

func _process(delta: float) -> void:
	time += delta * 2.5
	$Gem.rotation.y += delta * 1.6
	$Gem.position.y = sin(time) * 0.18
	$Halo.rotation.y -= delta

func _collect(body: Node3D) -> void:
	if taken or not body.is_in_group("player"):
		return
	taken = true
	set_deferred("monitoring", false)
	get_tree().current_scene.collect_crystal()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE * 0.01, 0.22)
	tween.tween_property(self, "position:y", position.y + 1.5, 0.22)
	tween.chain().tween_callback(queue_free)
