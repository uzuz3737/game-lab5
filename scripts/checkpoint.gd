extends Area3D
var activated := false
func _ready() -> void:
	body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group("player") and not activated:
			activated = true
			get_tree().current_scene.set_checkpoint(global_position + Vector3(0, 0.6, 1.5))
			$Beacon.material_override = load("res://assets/materials/mint.tres")
	)
