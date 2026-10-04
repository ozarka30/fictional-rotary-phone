@tool
class_name ActionDef extends Resource

@export var id: StringName
@export var name: String
@export var stat_deltas: Dictionary[Types.Stat, float] = {}
@export var is_rest := false  # counts as an idle day
@export var duration := 1.0   # seconds of avatar work
