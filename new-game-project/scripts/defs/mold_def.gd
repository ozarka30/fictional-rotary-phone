@tool
class_name MoldDef extends Resource
## The body: how much dough and how many mix-ins it takes, and the cap on every stat.

@export var id: StringName
@export var name: String
@export var creature_name: String  # what a Hearthling baked in it is called
@export var icon: Texture2D
@export var cost := 0
@export var dough_slots := 1
@export var mixin_slots := 1
@export var stat_caps: Dictionary[Types.Stat, float] = {}
@export var traits: Array[StringName] = []
@export var uses := -1  # -1 = unlimited; late-game molds wear out
