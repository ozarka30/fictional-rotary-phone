extends Node
## Ending the day: every Hearthling's night (shaping, settling, training), then the next morning.


func _ready() -> void:
	EventBus.sleep_requested.connect(sleep)


func sleep() -> void:
	EventBus.day_ending.emit(GameState.day)
	var notes := PackedStringArray()
	for h: HearthlingData in GameState.hearthlings.values():
		if Shaping.end_day(h, Database.get_def(&"pens", h.pen_id)):
			notes.append("#%d has settled" % h.uid)
			EventBus.hearthling_stabilized.emit(h)
	for yard in Training.YARDS:
		for uid in GameState.yard_slots.get(yard.id, []):
			if GameState.hearthlings.has(uid):
				Training.train(GameState.hearthlings[uid], yard.stats)
	GameState.day += 1
	for a in GameState.active_requests:
		if not a.fulfilled and a.due_day == GameState.day:
			notes.append("%s is back today" % a.def.customer_name)
	Nav.note = "Day %d: %s" % [GameState.day, ", ".join(notes) if notes else "a quiet morning."]
	EventBus.day_started.emit(GameState.day)
