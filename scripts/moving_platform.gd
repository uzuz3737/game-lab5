extends AnimatableBody3D
@export var travel := Vector3(0, 0, 5)
@export var period := 5.0
var origin := Vector3.ZERO
var time := 0.0
func _ready() -> void:
	origin = position
func _physics_process(delta: float) -> void:
	time += delta
	position = origin + travel * sin(time * TAU / period)
