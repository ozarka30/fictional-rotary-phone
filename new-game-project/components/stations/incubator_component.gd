class_name IncubatorComponent extends Node
## Holds one egg. Its HATCH task locks the machine's mana and hatches the egg into the pen.

@export var machine: MachineDef
@export var egg: EggDef  # ponytail: preset for testing until the front desk hands eggs over
@export var pen_path := NodePath("../../Pen")

var _hatching := false


func _ready() -> void:
	EventBus.egg_received.connect(func(e): egg = e)


func configure_task(t: Task) -> void:
	t.check = func() -> String:
		if egg == null:
			return "No egg to hatch"
		if _hatching:
			return "Already hatching"
		if not GameState.lock_mana(machine.id, machine.mana_cost):
			return "Not enough mana"
		_hatching = true  # ponytail: the queue runs check once, on accept
		return ""
	t.apply = _hatch


func _hatch() -> void:
	var family: FamilyDef = Database.get_def(&"families", egg.family_id)
	var data := Hatching.hatch(egg, family, GameState.new_uid())
	egg = null
	_hatching = false
	get_tree().get_first_node_in_group(&"hearthling_spawner").spawn(data, get_node(pen_path))
