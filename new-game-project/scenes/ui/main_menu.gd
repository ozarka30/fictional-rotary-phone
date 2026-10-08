extends Control
## A home page: every MenuCard in it opens one area of the shop, with a callout on hover.
## Used by main_page.tscn. An optional %Status label shows what needs doing today.

signal page_selected(page: StringName)


func _ready() -> void:
	for card: MenuCard in find_children("*", "MenuCard", true, false):
		card.pressed.connect(func(p):
			page_selected.emit(p)
			if Nav.PAGES.has(p):
				Nav.go(p)
			else:
				%Callout.say("Coming soon.", card.global_position + Vector2(card.size.x * 0.5, 8)))
		if card.blurb:
			card.mouse_entered.connect(func(): %Callout.say(card.blurb, card.global_position + Vector2(card.size.x * 0.5, 8)))
			card.mouse_exited.connect(%Callout.hide)
	var status := get_node_or_null(^"%Status") as Label
	if status:
		status.text = today()


## One line of what needs doing, for the top banner.
static func today() -> String:
	var bits := PackedStringArray()
	var back := GameState.active_requests.filter(func(a): return not a.fulfilled and GameState.day >= a.due_day)
	for a in back:
		bits.append("%s is back for their Hearthling" % a.def.customer_name)
	if GameState.waiting and back.is_empty():
		bits.append("%s is waiting at the desk" % GameState.waiting[0].customer_name)
	if GameState.eggs:
		bits.append("%d egg(s) to hatch" % GameState.eggs.size())
	var hungry := GameState.hearthlings.values().filter(func(h): return Shaping.can_shape(h) and not h.fed_today).size()
	if hungry:
		bits.append("%d need food" % hungry)
	return "   -   ".join(bits) if bits else "All caught up. Sleep when you're ready."
