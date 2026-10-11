extends Node3D
var helper: CanvasLayer
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	helper = load("res://scripts/hud.gd").new()
	# Reuse UI constructors without attaching the gameplay HUD script.
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)
	var theme := Theme.new()
	theme.default_font = load("res://assets/ui/NotoSansThai.ttf")
	theme.default_font_size = 18
	root.theme = theme
	var card: Panel = helper.panel(root, Vector2(44, 45), Vector2(448, 630), Color("f5f2e7"))
	helper.label(card, "A LOW-POLY PLATFORMING ADVENTURE", Vector2(34, 27), 13, Color("557480"))
	helper.label(card, "SKYBOUND", Vector2(30, 73), 48, Color("102b38"))
	helper.label(card, "COURIER", Vector2(30, 126), 48, Color("102b38"))
	helper.label(card, "ผู้ส่งพลังงานแห่งเกาะลอยฟ้า", Vector2(34, 199), 23, Color("557480"))
	helper.label(card, "รวบรวมคริสตัลให้ครบ หลบกับดัก\nข้ามเกาะลอยฟ้า และเปิดประตูสู่ด่านถัดไป", Vector2(34, 248), 18, Color("102b38"))
	helper.label(card, "01  MOSS GARDENS\n02  AMBER WORKS", Vector2(34, 332), 18, Color("557480"))
	var start: Button = helper.button(card, "เริ่มการเดินทาง   →", Vector2(34, 421), _start)
	start.size.x = 380
	start.grab_focus()
	helper.label(card, "WASD / ลูกศร  เดิน   •   เมาส์  หมุนกล้อง\nSPACE  กระโดดสองครั้ง   •   SHIFT  วิ่ง\nESC  พักเกม   •   R  เริ่มด่านใหม่", Vector2(34, 491), 15, Color("557480"))
	helper.label(root, "LAB 05   /   FIRST 3D GAME", Vector2(-314, -44), 14, Color("102b38"))
	var signature: Label = root.get_child(root.get_child_count() - 1)
	signature.anchor_left = 1
	signature.anchor_right = 1
	signature.anchor_top = 1
	signature.anchor_bottom = 1
func _start() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
func _exit_tree() -> void:
	if is_instance_valid(helper):
		helper.free()
