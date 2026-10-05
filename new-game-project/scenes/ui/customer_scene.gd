extends Control
## Talking to a customer gets its own screen: a backdrop, the customer, and dialog boxes.
## Dialog lines starting with "> " are the player's replies; several in a row become choices.
## A new customer ends on their request card; a returning one just talks (delivery is next).

@export var reply_style: StyleBox

const TYPE_SPEED := 0.02  # seconds per character
const GRADE_FONT := "res://art/fonts/Mastro-Regular.ttf"

var _customer: Node
var _giver: RequestGiverComponent
var _dialog: DialogDef
var _i := 0
var _typing: Tween
var _choosing := false


func _ready() -> void:
	hide()  # visible in the editor for layout; UIManager shows it
	add_to_group(&"panel")
	%Accept.pressed.connect(_accept)


func open(customer: Node) -> void:
	_customer = customer
	_giver = Components.get_one(customer, RequestGiverComponent) as RequestGiverComponent
	_dialog = _giver.active.def.return_dialog if _giver.active else _giver.request.intro_dialog
	%Name.text = _dialog.speaker.to_upper()
	%Portrait.texture = _dialog.portrait
	# ponytail: no portrait art yet, so show the customer's own sprite big
	%Sprite.visible = _dialog.portrait == null
	%Sprite.sprite_frames = customer.get_node(^"Sprite").sprite_frames
	%Sprite.play(&"breathing")
	%DialogBox.show()
	%RequestCard.hide()
	_i = 0
	EventBus.dialog_requested.emit(_dialog)
	_show_line()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and %DialogBox.visible and not _choosing:
		if _typing and _typing.is_running():
			_typing.kill()
			%Text.visible_ratio = 1.0
		else:
			_show_line()


func _show_line() -> void:
	for c in %Replies.get_children():
		c.queue_free()
	if _i >= _dialog.lines.size():
		_finish()
		return
	var line := _dialog.lines[_i]
	if line.begins_with("> "):
		_choosing = true
		while _i < _dialog.lines.size() and _dialog.lines[_i].begins_with("> "):
			_option(_dialog.lines[_i].substr(2), func(): _choosing = false; _show_line())
			_i += 1
		_option("Skip", _finish)
		return
	_option("Skip", _finish)
	_i += 1
	%Text.text = line
	%Text.visible_ratio = 0.0
	_typing = create_tween()
	_typing.tween_property(%Text, "visible_ratio", 1.0, line.length() * TYPE_SPEED)


## One dialog option box. Skip is always the last one.
func _option(text: String, on_press: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE
	for state in [&"normal", &"hover", &"pressed"]:
		var style: StyleBoxTexture = reply_style.duplicate()
		style.modulate_color = {&"normal": Color.WHITE, &"hover": Color(0.85, 0.85, 0.85), &"pressed": Color(0.7, 0.7, 0.7)}[state]
		b.add_theme_stylebox_override(state, style)
	b.add_theme_color_override(&"font_color", Color(0.08, 0.08, 0.08))
	b.add_theme_color_override(&"font_hover_color", Color(0, 0, 0))
	b.add_theme_color_override(&"font_pressed_color", Color(0, 0, 0))
	b.add_theme_font_size_override(&"font_size", 20)
	b.pressed.connect(on_press)
	%Replies.add_child(b)


func _finish() -> void:
	_choosing = false
	EventBus.dialog_finished.emit(_dialog.id)
	if _giver.active:
		_leave()
		return
	var r := _giver.request
	var needs := PackedStringArray()
	for st in r.min_stats:
		needs.append(_chip("%s %s" % [Types.Stat.keys()[st].capitalize(), _grade(r.min_stats[st])], Types.STAT_COLORS[st]))
	for a in r.min_affinities:
		needs.append(_chip("%s %s" % [Types.Affinity.keys()[a].capitalize(), _grade(r.min_affinities[a])], Types.AFFINITY_COLORS[a]))
	%CardTitle.text = "%s's request" % r.customer_name
	%CardText.text = "%s\n\nNeeds: %s\nBack in %s  -  Reward: %s" % [r.summary, ", ".join(needs),
		_chip("%d days" % r.return_after_days, Types.DAYS_COLOR), _chip("%d coin" % r.reward_coin, Types.COIN_COLOR)]
	%Accept.text = "Take the egg" if r.egg else "Accept"
	%DialogBox.hide()
	%RequestCard.show()


## Colored, ink-outlined text for the parts of a request that matter.
func _chip(text: String, color: Color) -> String:
	return "[outline_size=5][outline_color=#181818][color=#%s]%s[/color][/outline_color][/outline_size]" % [color.to_html(false), text]



## Grade letters get their own chunky font so they pop.
func _grade(g: Types.Grade) -> String:
	return "[font=%s][font_size=26]%s+[/font_size][/font]" % [GRADE_FONT, Types.grade_name(g)]


func _accept() -> void:
	var r := _giver.request
	var active := ActiveRequest.start(r, GameState.day)
	GameState.active_requests.append(active)
	get_tree().get_first_node_in_group(&"customer_manager").schedule_return(r, active.due_day)
	EventBus.request_received.emit(active)
	if r.egg:
		EventBus.egg_received.emit(r.egg)
	_leave()


func _leave() -> void:
	get_tree().get_first_node_in_group(&"ui_manager").close()
	get_tree().get_first_node_in_group(&"customer_manager").leave(_customer)
