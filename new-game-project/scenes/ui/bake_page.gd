extends Control
## Bake: pick a mold, fill its dough slots, add mix-ins, press in a Heartseed, then bake.
## Baking is instant and uses up the dough, mix-ins, Heartseed and one mold use (if the mold has limited uses).

var _mold: MoldDef
var _doughs: Array = []   # DoughDef or null per slot
var _mixins: Array = []   # MixinDef or null per slot
var _seed: Heartseed


func _ready() -> void:
	%BakeButton.pressed.connect(_bake)
	_refresh()


func _refresh() -> void:
	for c in %Slots.get_children():
		c.queue_free()
	_row("MOLD", _mold.name if _mold else "Choose a mold", _pick_mold)
	if _mold:
		_doughs.resize(Baking.dough_slots(_mold, _filled(_mixins)))
		_mixins.resize(_mold.mixin_slots)
		for i in _doughs.size():
			_row("DOUGH" if i == 0 else "", _doughs[i].name if _doughs[i] else "Required", _pick.bind(&"doughs", _doughs, i))
		for i in _mixins.size():
			_row("MIX-INS" if i == 0 else "", _mixins[i].name if _mixins[i] else "Optional", _pick.bind(&"mixins", _mixins, i))
	_row("CORE", _seed.name if _seed else "Required", _pick_seed)
	var problem := Baking.check(_mold, _filled(_doughs), _filled(_mixins), _seed)
	%BakeButton.disabled = not problem.is_empty()
	%Preview.text = problem if problem else InfoPopup.describe(_preview())


## A label (if any) and a button for one slot.
func _row(label: String, text: String, on_press: Callable) -> void:
	if label:
		var l := Label.new()
		l.text = label
		l.add_theme_font_override(&"font", preload("res://art/fonts/Supro-Regular.ttf"))
		l.add_theme_font_size_override(&"font_size", 28)
		l.add_theme_color_override(&"font_color", Types.COIN_COLOR)
		%Slots.add_child(l)
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(on_press)
	%Slots.add_child(b)


func _pick_mold() -> void:
	var owned := Database.get_all(&"molds").filter(func(m): return GameState.molds.get(m.id, 0) != 0)
	var labels := PackedStringArray(owned.map(func(m):
		var uses: int = GameState.molds[m.id]
		return m.name + ("" if uses < 0 else "  (%d uses left)" % uses)))
	var pick: int = await %Chooser.ask("Mold", labels)
	if pick >= 0:
		_mold = owned[pick]
	_refresh()


## Dough or mix-in slot `i`: owned items, minus the ones already in other slots.
func _pick(category: StringName, slots: Array, i: int) -> void:
	var have := Database.get_all(category).filter(func(d): return _left(d) > 0 or slots[i] == d)
	var labels := PackedStringArray(["(empty)"])
	labels.append_array(have.map(func(d): return "%s x%d  -  %s" % [d.name, _left(d) + (1 if slots[i] == d else 0), Ink.plain(Ink.effects(d))]))
	var pick: int = await %Chooser.ask("Dough" if category == &"doughs" else "Mix-in", labels)
	if pick >= 0:
		slots[i] = null if pick == 0 else have[pick - 1]
	_refresh()


func _pick_seed() -> void:
	if GameState.heartseeds.is_empty():
		%Callout.say("No Heartseeds. Customers bring them, or buy a Null Heartseed at the Market.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask("Heartseed", PackedStringArray(GameState.heartseeds.map(func(s): return "%s #%d" % [s.name, s.uid])))
	if pick >= 0:
		_seed = GameState.heartseeds[pick]
	_refresh()


func _bake() -> void:
	var doughs := _filled(_doughs)
	var mixins := _filled(_mixins)
	for d in doughs + mixins:
		GameState.add_material(d.id, -1)
	if GameState.molds[_mold.id] > 0:
		GameState.molds[_mold.id] -= 1
	GameState.heartseeds.erase(_seed)
	var h := Baking.bake(GameState.new_uid(), _mold, doughs, mixins, _seed)
	GameState.hearthlings[h.uid] = h
	EventBus.hearthling_baked.emit(h)
	%Callout.say("%s is out of the oven! Put it in the Training Yard." % h.name, %BakeButton.global_position)
	_doughs.clear()
	_mixins.clear()
	_seed = null
	if GameState.molds[_mold.id] == 0:
		_mold = null
	_refresh()


## What the recipe would bake into, without touching the real Heartseed.
func _preview() -> HearthlingData:
	return Baking.bake(0, _mold, _filled(_doughs), _filled(_mixins), _seed.duplicate(true))


func _left(def: Resource) -> int:
	return GameState.materials.get(def.id, 0) - (_doughs + _mixins).count(def)


func _filled(slots: Array) -> Array:
	return slots.filter(func(x): return x != null)
