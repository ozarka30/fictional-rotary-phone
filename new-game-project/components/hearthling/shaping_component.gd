class_name ShapingComponent extends Node
## The shaping window: builds the day's FEED / ACT / MOVE_PEN tasks for its
## Hearthling and runs the overnight phases (DayManager calls the "growth" group).

@onready var _state := Components.get_one(get_parent(), HearthlingStateComponent) as HearthlingStateComponent

var _today := DayEntry.new()
var _rested := false


func _init() -> void:
	add_to_group(&"growth")


func data() -> HearthlingData:
	return _state.data


func pen() -> PenDef:
	return Database.get_def(&"pens", data().pen_id)


func can_shape() -> bool:
	return not data().stabilized and data().malleable_days_left > 0


func feed_task(food: FoodDef) -> Task:
	var t := _task(Task.Kind.FEED, food.id)
	t.check = func() -> String:
		if not can_shape():
			return "It has settled"
		if data().fed_today:
			return "Already fed today"
		data().fed_today = true  # ponytail: reserved when the queue accepts
		return ""
	t.apply = func():
		Shaping.feed(data(), food, pen())
		_today.food_id = food.id
		EventBus.hearthling_changed.emit(data())
	return t


func act_task(action: ActionDef) -> Task:
	var t := _task(Task.Kind.ACT, action.id)
	t.duration = action.duration
	t.check = func() -> String:
		if not can_shape():
			return "It has settled"
		if data().acted_today:
			return "Already did an action today"
		data().acted_today = true
		return ""
	t.apply = func():
		Shaping.act(data(), action)
		_today.action_id = action.id
		_rested = action.is_rest
		EventBus.hearthling_changed.emit(data())
	return t


## Pens with a mana cost hold it per Hearthling until it moves back to a free pen.
func pen_task(p: PenDef) -> Task:
	var lock := StringName("pen_%d" % data().uid)
	var t := _task(Task.Kind.MOVE_PEN, p.id)
	t.check = func() -> String:
		if data().pen_id == p.id:
			return "Already in that pen"
		if p.mana_cost > 0 and not GameState.lock_mana(lock, p.mana_cost):
			return "Not enough mana"
		return ""
	t.apply = func():
		if p.mana_cost == 0:
			GameState.unlock_mana(lock)
		data().pen_id = p.id
		EventBus.hearthling_changed.emit(data())
	return t


func apply_night() -> void:
	if not can_shape():
		return
	Shaping.night(data(), pen(), _rested)
	_today.day = GameState.day
	_today.pen_id = data().pen_id
	data().history.append(_today)
	_today = DayEntry.new()
	_rested = false


func stabilize_if_ready() -> void:
	if data().malleable_days_left == 0 and not data().stabilized:
		data().stabilized = true  # ponytail: step 5 locks form, potentials and traits here
		EventBus.hearthling_stabilized.emit(data())


func reset_daily() -> void:
	data().fed_today = false
	data().acted_today = false


func _task(kind: Task.Kind, payload: StringName) -> Task:
	var t := Task.new()
	t.kind = kind
	t.target = get_parent()
	t.hearthling_uid = data().uid
	t.payload_id = payload
	return t
