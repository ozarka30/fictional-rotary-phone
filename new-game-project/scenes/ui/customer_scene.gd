extends Control
## Talking to a customer gets its own screen: a backdrop, the customer, and dialog boxes.
## Dialog lines starting with "> " are the player's replies; several in a row become choices.
## A new customer ends on their request card; a returning one picks a Hearthling and rates it.

@export var reply_style: StyleBox

const TYPE_SPEED := 0.02  # seconds per character

signal finished

var _request: RequestDef
var _active: ActiveRequest
var _dialog: DialogDef
var _i := 0
var _typing: Tween
var _choosing := false


func _ready() -> void:
	%Accept.pressed.connect(_accept)


## A new customer (no `active`) or one coming back for `active`.
func open_request(r: RequestDef, active: ActiveRequest = null) -> void:
	_request = r
	_active = active
	_dialog = r.return_dialog if active else r.intro_dialog
	%Name.text = _dialog.speaker.to_upper()
	%Portrait.texture = _dialog.portrait
	# ponytail: no portrait art yet, so show the customer's own sprite big
	%Sprite.visible = _dialog.portrait == null and r.customer_frames != null
	%Sprite.sprite_frames = r.customer_frames
	%Sprite.play(&"breathing")
	show()
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
	if _active:
		_offer_hearthlings()
		return
	var r := _request
	var needs := PackedStringArray()
	for st in r.min_stats:
		needs.append(Ink.chip("%s %s" % [Types.Stat.keys()[st].capitalize(), Ink.grade(r.min_stats[st], "+")], Types.STAT_COLORS[st]))
	for a in r.min_affinities:
		needs.append(Ink.chip("%s %s" % [Types.Affinity.keys()[a].capitalize(), Ink.grade(r.min_affinities[a], "+")], Types.AFFINITY_COLORS[a]))
	%CardTitle.text = "%s's request" % r.customer_name
	%CardText.text = "%s\n\nNeeds: %s\nBack in %s  -  Reward: %s" % [r.summary, ", ".join(needs),
		Ink.chip("%d days" % r.return_after_days, Types.DAYS_COLOR), Ink.chip("%d coin" % r.reward_coin, Types.COIN_COLOR)]
	%Accept.text = "Take the egg" if r.egg else "Accept"
	%DialogBox.hide()
	%RequestCard.show()


## Returning customer: pick which settled Hearthling to hand over.
func _offer_hearthlings() -> void:
	for c in %Replies.get_children():
		c.queue_free()
	%Text.text = "So, which one is mine?"
	%Text.visible_ratio = 1.0
	_choosing = true
	for h: HearthlingData in GameState.hearthlings.values():
		if h.stabilized:
			var family: FamilyDef = Database.get_def(&"families", h.family_id)
			_option("%s #%d" % [family.name, h.uid], _deliver.bind(h))
	_option("Not ready yet", finished.emit)


func _deliver(h: HearthlingData) -> void:
	var r := _request
	var stars := Scoring.stars(h, r)
	var happy := Scoring.meets(h, r)
	_active.fulfilled = true
	_active.grade = stars
	GameState.hearthlings.erase(h.uid)
	for slots in GameState.yard_slots.values():
		for i in slots.size():
			if slots[i] == h.uid:
				slots[i] = -1
	if happy:
		GameState.add_coin(r.reward_coin)
	EventBus.request_completed.emit(_active, stars)
	%CardTitle.text = "%s's verdict" % r.customer_name
	%CardText.text = "[font=%s][font_size=40]%d / 5 STARS[/font_size][/font]\n\n%s" % [Ink.GRADE_FONT, stars,
		"Exactly what I needed. Here's %s." % Ink.chip("%d coin" % r.reward_coin, Types.COIN_COLOR) if happy else "This isn't what I asked for. No pay this time."]
	%Accept.text = "Back to the shop"
	%DialogBox.hide()
	%RequestCard.show()


func _accept() -> void:
	if _active:  # the verdict card
		finished.emit()
		return
	var r := _request
	var active := ActiveRequest.start(r, GameState.day)
	GameState.active_requests.append(active)
	GameState.waiting.erase(r)
	EventBus.request_received.emit(active)
	if r.egg:
		GameState.eggs.append(r.egg)
		EventBus.egg_received.emit(r.egg)
	finished.emit()
