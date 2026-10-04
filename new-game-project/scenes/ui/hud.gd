extends Control
## Day, clock and mana readout, plus the Sleep button.

@onready var _day: Label = %Day
@onready var _clock: Label = %Clock
@onready var _mana: Label = %Mana


func _ready() -> void:
	EventBus.day_started.connect(func(_d): _refresh())
	EventBus.clock_changed.connect(func(_m): _refresh())
	EventBus.mana_changed.connect(func(_f, _c): _refresh())
	%Sleep.pressed.connect(EventBus.sleep_requested.emit)
	_refresh()


func _refresh() -> void:
	var m := int(DayManager.minutes)
	_day.text = "Day %d" % GameState.day
	_clock.text = "%02d:%02d" % [m / 60, m % 60]
	_mana.text = "Mana %d / %d" % [GameState.free_mana(), GameState.mana_capacity]
