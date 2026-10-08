extends PanelContainer
## The shaping workbench for one Hearthling: today's food and action, its pen, and a lean preview.
## Confirm applies the picks straight away; they count once per day.

signal closed

var _h: HearthlingData
var _food: FoodDef
var _action: ActionDef
var _pen: PenDef

@onready var _box := VBoxContainer.new()


func _ready() -> void:
	hide()
	add_child(_box)


func open(h: HearthlingData) -> void:
	_h = h
	_food = null
	_action = null
	_pen = Database.get_def(&"pens", h.pen_id)
	_rebuild()
	show()


func _rebuild() -> void:
	for c in _box.get_children():
		c.queue_free()
	var family: FamilyDef = Database.get_def(&"families", _h.family_id)
	var shaping := Shaping.can_shape(_h)
	_label("%s #%d  -  %s" % [family.name, _h.uid, "%d shaping day(s) left" % _h.malleable_days_left if shaping else "settled"], 24)
	if shaping:
		_choices("Food", Database.get_all(&"foods"), _food, _h.fed_today, func(d): _food = d)
		_choices("Action", Database.get_all(&"actions"), _action, _h.acted_today, func(d): _action = d)
		_choices("Pen", Database.get_all(&"pens").slice(0, 4), _pen, false, func(d): _pen = d)
	_preview()
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	_box.add_child(row)
	_button(row, "Confirm", _confirm).visible = shaping
	_button(row, "Close", _close)


func _choices(title: String, defs: Array, picked: Resource, done: bool, pick: Callable) -> void:
	var row := HBoxContainer.new()
	_box.add_child(row)
	var l := _label(title + (" (done)" if done else ""), 18, row)
	l.custom_minimum_size.x = 120
	for d in defs:
		var b := _button(row, d.name, func(): pick.call(d); _rebuild())
		b.toggle_mode = true
		b.button_pressed = d == picked
		b.disabled = done


func _preview() -> void:
	var p := Shaping.preview(_h, _food, _action, _pen)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override(&"h_separation", 18)
	_box.add_child(grid)
	var cells := []
	for s in Types.Stat.values():
		cells.append([Types.Stat.keys()[s].capitalize(), "%s %d/%d" % [Types.grade_name(_h.stat_grade(s)), _h.stats[s], _h.potentials[s]],
			"%s %d/%d" % [Types.grade_name(p.stat_grade(s)), p.stats[s], p.potentials[s]], Types.STAT_COLORS[s]])
	for a in range(1, Types.Affinity.size()):
		cells.append([Types.Affinity.keys()[a].capitalize(), "%s %d" % [Types.grade_name(_h.affinity_grade(a)), _h.affinities.get(a, 0.0)],
			"%s %d" % [Types.grade_name(p.affinity_grade(a)), p.affinities.get(a, 0.0)], Types.AFFINITY_COLORS[a]])
	for i in cells.size():  # two columns of name / value pairs
		var c: Array = cells[i]
		var name_label := _label(c[0], 16, grid)
		name_label.add_theme_color_override(&"font_color", c[3].darkened(0.25))
		var v := _label(c[1] if c[1] == c[2] else "%s -> %s" % [c[1], c[2]], 16, grid)
		if c[1] != c[2]:
			v.add_theme_color_override(&"font_color", Color("0e7a46"))
	if _pen.affinity != Types.Affinity.NONE:
		_label("%s: +%d %s each night" % [_pen.name, _pen.push_per_day, Types.Affinity.keys()[_pen.affinity].capitalize()], 16)


func _confirm() -> void:
	_h.pen_id = _pen.id
	if _food and not _h.fed_today:
		Shaping.give_food(_h, _food, _pen)
	if _action and not _h.acted_today:
		Shaping.give_action(_h, _action)
	EventBus.hearthling_changed.emit(_h)
	_close()


func _close() -> void:
	hide()
	closed.emit()


func _label(text: String, font_size := 18, parent: Node = _box) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override(&"font_size", font_size)
	parent.add_child(l)
	return l


func _button(parent: Node, text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(on_press)
	parent.add_child(b)
	return b
