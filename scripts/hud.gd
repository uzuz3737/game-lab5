extends CanvasLayer
var root: Control
var counter: Label
var clock_label: Label
var notice: Label
var overlay: Control
var level: Node
var notice_left := 0.0
const INK := Color("102b38")
const MUTED := Color("557480")
const MINT := Color("a8f0c9")
const CREAM := Color("f5f2e7")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level = get_parent()
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var font = load("res://assets/ui/NotoSansThai.ttf")
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 18
	root.theme = theme
	var card := panel(root, Vector2(28, 26), Vector2(318, 105), CREAM)
	label(card, "SKYBOUND  /  COURIER", Vector2(20, 12), 14, MUTED)
	label(card, "%02d   %s" % [level.level_number, level.level_title], Vector2(20, 36), 24, INK)
	label(card, "เก็บคริสตัล • หลบกับดัก • ไปที่ประตู", Vector2(20, 73), 14, MUTED)
	var stats := panel(root, Vector2(-286, 26), Vector2(258, 105), INK)
	stats.anchor_left = 1.0
	stats.anchor_right = 1.0
	counter = label(stats, "", Vector2(20, 13), 24, MINT)
	clock_label = label(stats, "", Vector2(20, 61), 15, Color("d0dde0"))
	var controls := panel(root, Vector2(28, -69), Vector2(614, 42), Color(0.06, 0.16, 0.2, 0.9))
	controls.anchor_top = 1.0
	controls.anchor_bottom = 1.0
	label(controls, "WASD / ลูกศร  เดิน     SPACE  กระโดดสองครั้ง     SHIFT  วิ่ง     ESC  พัก", Vector2(16, 9), 15, CREAM)
	notice = label(root, "", Vector2(-350, -122), 21, CREAM)
	notice.anchor_left = 0.5
	notice.anchor_right = 0.5
	notice.anchor_top = 1.0
	notice.anchor_bottom = 1.0
	notice.size = Vector2(700, 42)
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_theme_color_override("font_shadow_color", INK)
	notice.add_theme_constant_override("shadow_offset_x", 2)
	notice.add_theme_constant_override("shadow_offset_y", 2)
	update_stats()

func panel(parent: Node, at: Vector2, dimensions: Vector2, color: Color) -> Panel:
	var p := Panel.new()
	p.position = at
	p.size = dimensions
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0.02, 0.12, 0.16, 0.15)
	style.shadow_size = 6
	p.add_theme_stylebox_override("panel", style)
	parent.add_child(p)
	return p

func label(parent: Node, text: String, at: Vector2, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = at
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l

func button(parent: Node, text: String, at: Vector2, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.position = at
	b.size = Vector2(340, 48)
	for font_state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(font_state, INK)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = MINT.lightened(0.15) if state == "hover" else MINT
		style.set_corner_radius_all(10)
		b.add_theme_stylebox_override(state, style)
	b.pressed.connect(callback)
	parent.add_child(b)
	return b

func update_stats() -> void:
	if not counter:
		return
	counter.text = "CRYSTALS   %02d / %02d" % [level.collected, level.total_crystals]
	clock_label.text = "%02d:%02d     •     พลาด %d ครั้ง" % [int(level.elapsed / 60.0), int(level.elapsed) % 60, level.falls]

func message(text: String, duration: float) -> void:
	notice.text = text
	notice_left = duration

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	notice_left = maxf(0.0, notice_left - delta)
	notice.visible = notice_left > 0.0
	update_stats()

func show_overlay(title: String, detail: String, won := false) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.11, 0.15, 0.68)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var card := panel(overlay, Vector2(-210, -195), Vector2(420, 390), CREAM)
	card.anchor_left = 0.5
	card.anchor_right = 0.5
	card.anchor_top = 0.5
	card.anchor_bottom = 0.5
	label(card, "SKYBOUND COURIER", Vector2(40, 25), 14, MUTED)
	label(card, title, Vector2(40, 57), 32, INK)
	label(card, detail, Vector2(40, 117), 17, MUTED)
	button(card, "เล่นอีกครั้ง" if won else "เล่นต่อ", Vector2(40, 203), level.restart_game if won else level.resume_game)
	button(card, "กลับเมนูหลัก", Vector2(40, 263), level.go_to_menu)
	label(card, "R  เริ่มด่านใหม่   •   ESC  เล่นต่อ", Vector2(40, 331), 14, MUTED)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
