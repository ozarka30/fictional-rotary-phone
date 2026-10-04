extends PanelContainer
## Pick today's food, action and pen for one Hearthling, with a lean preview.
## Confirm queues the picks as avatar tasks. Built in code; it's all lists.

var _shaping: ShapingComponent
var _food: FoodDef
var _action: ActionDef
var _pen: PenDef

@onready var _box := VBoxContainer.new()


func _ready() -> void:
	add_to_group(&"panel")
	add_child(_box)


func open(entity: Node) -> void:
	_shaping = Components.get_one(entity, ShapingComponent) as ShapingComponent
	_food = null
	_action = null
	_pen = _shaping.pen()
	_rebuild()


func _rebuild() -> void:
	for c in _box.get_children():
		c.queue_free()
	var h := _shaping.data()
	_label("Hearthling #%d  -  %d shaping day(s) left" % [h.uid, h.malleable_days_left], 20)
	if not _shaping.can_shape():
		_label("It has settled.")
	else:
		_choices("Food", Database.get_all(&"foods"), _food, h.fed_today, func(d): _food = d)
		_choices("Action", Database.get_all(&"actions"), _action, h.acted_today, func(d): _action = d)
		_choices("Pen", Database.get_all(&"pens"), _pen, false, func(d): _pen = d)
	_preview(h)
	var row := HBoxContainer.new()
	_box.add_child(row)
	_button(row, "Confirm", _confirm).disabled = not _shaping.can_shape()
	_button(row, "Close", _close)


func _choices(title: String, defs: Array, picked: Resource, done: bool, pick: Callable) -> void:
	var row := HBoxContainer.new()
	_box.add_child(row)
	var l := Label.new()
	l.text = title + (" (done today)" if done else "")
	l.custom_minimum_size.x = 150
	row.add_child(l)
	for d in defs:
		var b := _button(row, d.name, func(): pick.call(d); _rebuild())
		b.toggle_mode = true
		b.button_pressed = d == picked
		b.disabled = done
		if d is PenDef and d.mana_cost > 0:
			b.text += " (%d mana)" % d.mana_cost


func _preview(h: HearthlingData) -> void:
	var p := Shaping.preview(h, _food, _action, _pen)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override(&"h_separation", 24)
	_box.add_child(grid)
	for s in Types.Stat.values():
		_row(grid, Types.Stat.keys()[s].capitalize(), "%s %d/%d" % [Types.grade_name(h.stat_grade(s)), h.stats[s], h.potentials[s]],
			"%s %d/%d" % [Types.grade_name(p.stat_grade(s)), p.stats[s], p.potentials[s]])
	for a in range(1, Types.Affinity.size()):
		_row(grid, Types.Affinity.keys()[a].capitalize(), "%s %d" % [Types.grade_name(h.affinity_grade(a)), h.affinities.get(a, 0.0)],
			"%s %d" % [Types.grade_name(p.affinity_grade(a)), p.affinities.get(a, 0.0)])
	if _pen.affinity != Types.Affinity.NONE:
		_label("%s: +%d %s each night" % [_pen.name, _pen.push_per_day, Types.Affinity.keys()[_pen.affinity].capitalize()])


func _row(grid: GridContainer, title: String, now: String, after: String) -> void:
	for text in [title, now, after]:
		var l := Label.new()
		l.text = text
		grid.add_child(l)
	if now != after:
		grid.get_child(-1).modulate = Color(0.6, 1, 0.6)
		grid.get_child(-1).text = "-> " + after


func _confirm() -> void:
	var coordinator := get_tree().get_first_node_in_group(&"game_coordinator")
	if _pen != _shaping.pen():
		coordinator.submit(_shaping.pen_task(_pen))
	if _food:
		coordinator.submit(_shaping.feed_task(_food))
	if _action:
		coordinator.submit(_shaping.act_task(_action))
	_close()


func _close() -> void:
	get_tree().get_first_node_in_group(&"ui_manager").close()


func _label(text: String, font_size := 16) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override(&"font_size", font_size)
	_box.add_child(l)


func _button(parent: Node, text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(on_press)
	parent.add_child(b)
	return b
