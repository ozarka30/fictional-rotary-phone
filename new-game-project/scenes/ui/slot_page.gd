class_name SlotPage extends Control
## A page with four options on top and five slots below that show the selected option.
## Subclasses say what the options and slots are.

const SLOTS := 5

var _sel := 0
var _options: Array  # each: {"id", "name", "blurb"}


## Override: the four options.
func options() -> Array:
	return []


## Override: what slot `i` of `option` shows, as {"title", "blurb"}.
func slot(option: Dictionary, i: int) -> Dictionary:
	return {"title": "Empty", "blurb": ""}


## Override: a slot was clicked.
func slot_pressed(option: Dictionary, i: int) -> void:
	print("slot %d in %s" % [i + 1, option.id])


func _ready() -> void:
	_options = options()
	for i in %Options.get_child_count():
		var card: MenuCard = %Options.get_child(i)
		card.visible = i < _options.size()
		if not card.visible:
			continue
		card.title = _options[i].name
		card.blurb = _options[i].blurb
		card.pressed.connect(func(_p): select(i))
		_callout(card)
	for i in SLOTS:
		var card: MenuCard = %Slots.get_child(i)
		card.pressed.connect(func(_p): slot_pressed(_options[_sel], i))
		_callout(card)
	select(0)


func select(i: int) -> void:
	_sel = i
	for j in %Options.get_child_count():
		%Options.get_child(j).modulate = Color.WHITE if j == i else Color(0.62, 0.62, 0.62)
	%Subtitle.text = _options[i].name
	for s in SLOTS:
		var card: MenuCard = %Slots.get_child(s)
		var info := slot(_options[i], s)
		card.title = info.title
		card.blurb = info.blurb


func _callout(card: MenuCard) -> void:
	card.mouse_entered.connect(func():
		if card.blurb:
			%Callout.say(card.blurb, card.global_position + Vector2(card.size.x * 0.5, 8)))
	card.mouse_exited.connect(%Callout.hide)
