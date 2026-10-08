extends Control
## Training Yard: pick one of four yards above; the five slots below show that yard.

# ponytail: yards as consts until they need costs, unlocks or art (then a YardDef in data/yards)
const YARDS := [
	{"id": &"obstacle_run", "name": "Obstacle Run", "stats": [Types.Stat.PACE, Types.Stat.BRAWN]},
	{"id": &"scent_trail", "name": "Scent Trail", "stats": [Types.Stat.KNACK, Types.Stat.WITS]},
	{"id": &"sparring_ring", "name": "Sparring Ring", "stats": [Types.Stat.GRIT, Types.Stat.BRAWN]},
	{"id": &"calm_garden", "name": "Calm Garden", "stats": [Types.Stat.HEART, Types.Stat.WITS]},
]
const SLOTS := 5

var _yard := 0


func _ready() -> void:
	var yards := %Yards.get_children()
	for i in yards.size():
		var card: MenuCard = yards[i]
		card.title = YARDS[i].name
		card.blurb = "Trains " + " and ".join(YARDS[i].stats.map(func(s): return Ink.chip(Types.Stat.keys()[s].capitalize(), Types.STAT_COLORS[s])))
		card.pressed.connect(func(_p): _select(i))
		_callout(card)
	for i in SLOTS:
		var slot: MenuCard = %Slots.get_child(i)
		slot.pressed.connect(func(_p): print("slot %d in %s" % [i + 1, YARDS[_yard].id]))  # ponytail: picking a Hearthling comes next
		_callout(slot)
	_select(0)


func _select(i: int) -> void:
	_yard = i
	var yard: Dictionary = YARDS[i]
	for j in %Yards.get_child_count():
		%Yards.get_child(j).modulate = Color.WHITE if j == i else Color(0.62, 0.62, 0.62)
	%Subtitle.text = yard.name
	var slots: Array = GameState.yard_slots.get_or_add(yard.id, [-1, -1, -1, -1, -1])
	for s in SLOTS:
		var slot: MenuCard = %Slots.get_child(s)
		var uid: int = slots[s]
		slot.title = "Empty" if uid < 0 else "#%d" % uid
		slot.blurb = "Place a Hearthling here to train it at the %s." % yard.name if uid < 0 else ""


func _callout(card: MenuCard) -> void:
	card.mouse_entered.connect(func():
		if card.blurb:
			%Callout.say(card.blurb, card.global_position + Vector2(card.size.x * 0.5, 8)))
	card.mouse_exited.connect(%Callout.hide)
