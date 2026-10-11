@tool
class_name MixinDef extends Resource
## A wild card: nudges caps or slots. Most have a downside; rare ones don't.

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var rare := false
@export var stat_caps: Dictionary[Types.Stat, float] = {}          # added to the mold's caps
@export var affinity_caps: Dictionary[Types.Affinity, float] = {}  # added to the dough's caps
@export var dough_slots := 0
