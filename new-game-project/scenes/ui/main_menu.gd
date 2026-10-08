extends Control
## A home page: every MenuCard in it opens one area of the shop, with a callout on hover.
## Used by main_menu.tscn and main_page.tscn. An optional %Status label shows day, mana and coin.

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
		var refresh := func(_a = null, _b = null): status.text = "Day %d    Mana %d / %d    %d coin" % [GameState.day, GameState.free_mana(), GameState.mana_capacity, GameState.coin]
		EventBus.day_started.connect(refresh)
		EventBus.mana_changed.connect(refresh)
		EventBus.coin_changed.connect(refresh)
		refresh.call()
