@tool
class_name RequestDef extends Resource
## What a customer wants. Every listed minimum must be met; fit grade comes from the margins.

@export var id: StringName
@export var customer_name: String
@export_multiline var summary: String
@export var min_stats: Dictionary[Types.Stat, Types.Grade] = {}
@export var min_affinities: Dictionary[Types.Affinity, Types.Grade] = {}
@export var egg: EggDef                 # egg the customer hands over, if any
@export var return_after_days := 5
@export var reward_coin := 0
@export var reward_materials: Dictionary[StringName, int] = {}
@export var intro_dialog: DialogDef
@export var return_dialog: DialogDef
