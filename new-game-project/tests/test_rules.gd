@tool
extends McpTestSuite
## Run from Claude via test_run, or the Godot AI dock.


func suite_name() -> String:
	return "rules"


func test_grade_bands() -> void:
	assert_eq(Types.grade_of(0.0), Types.Grade.E)
	assert_eq(Types.grade_of(39.9), Types.Grade.D)
	assert_eq(Types.grade_of(40.0), Types.Grade.C)
	assert_eq(Types.grade_of(100.0), Types.Grade.S)


func test_hearth_web() -> void:
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.BLOOM), HearthWeb.FEED_BONUS)
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.EMBER), HearthWeb.QUELL_PENALTY)
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.TIDE), 1.0)


func test_hunter_request_loads() -> void:
	var req: RequestDef = load("res://data/requests/hunter_tracker.tres")
	assert_eq(req.min_stats[Types.Stat.KNACK], Types.Grade.C)
	assert_eq(req.min_affinities[Types.Affinity.TIDE], Types.Grade.C)
	assert_eq(req.heartseed.name, "Null Heartseed")
	assert_eq(req.intro_dialog.lines.size(), 6)  # defs are @tool so the editor keeps real values


func test_bake_needs_every_dough_slot() -> void:
	var pup: MoldDef = load("res://data/molds/pup.tres")
	var brine: DoughDef = load("res://data/doughs/brine_dough.tres")
	var seed: Heartseed = load("res://data/seeds/null_heartseed.tres").duplicate(true)
	assert_eq(Baking.check(pup, [brine], [], seed), "This mold needs 2 dough.")
	assert_eq(Baking.check(pup, [brine, brine], [], null), "Choose a Heartseed.")
	assert_eq(Baking.check(pup, [brine, brine], [], seed), "")
	var leaven: MixinDef = load("res://data/mixins/leavening.tres")
	assert_eq(Baking.dough_slots(pup, [leaven]), 3)


func test_bake_caps_and_fresh_affinity() -> void:
	var seed: Heartseed = load("res://data/seeds/null_heartseed.tres").duplicate(true)
	var brine: DoughDef = load("res://data/doughs/brine_dough.tres")
	var h := Baking.bake(1, load("res://data/molds/pup.tres"), [brine, brine], [load("res://data/mixins/sea_salt.tres")], seed)
	assert_eq(h.affinity_caps[Types.Affinity.TIDE], 70.0)    # 30 + 30 + 10 sea salt
	assert_eq(h.affinity(Types.Affinity.TIDE), 17.5)         # a quarter of the cap
	assert_eq(h.affinity_caps.get(Types.Affinity.EMBER, 0.0), 0.0)  # sea salt can't go below 0
	assert_eq(h.stat(Types.Stat.KNACK), 0.0)
	assert_eq(h.traits(), [&"playful"])


func test_training_stops_at_caps_and_floors_at_zero() -> void:
	var h := _pup()
	Training.apply(h, {Types.Stat.KNACK: 80.0, Types.Stat.HEART: -5.0}, {})
	assert_eq(h.stat(Types.Stat.KNACK), 50.0)
	assert_eq(h.seed.stat_exp[Types.Stat.KNACK], 50.0)
	assert_eq(h.stat(Types.Stat.HEART), 0.0)


func test_toxicity_blocks_food() -> void:
	var h := _pup()
	var fish: FoodDef = load("res://data/foods/small_fish.tres")
	for i in 5:
		assert_true(Training.feed(h, fish))
	assert_eq(h.toxicity, Training.TOXICITY_MAX)
	assert_false(Training.feed(h, fish))


func test_remold_keeps_most_exp() -> void:
	var h := _pup()
	Training.apply(h, {Types.Stat.KNACK: 40.0}, {})
	var seed := Baking.remold(h)
	assert_eq(seed.stat_exp[Types.Stat.KNACK], 34.0)


## Hunter run: Pup with two Brine dough, 3 Small Fish, then 5 nights at Shoreline doing Scent Trail.
## Ends with C Knack (50, the Pup's cap) and C Tide (42): 3 stars.
func test_hunter_run_scores() -> void:
	var r: RequestDef = load("res://data/requests/hunter_tracker.tres")
	var h := _pup()
	for i in 3:
		Training.feed(h, load("res://data/foods/small_fish.tres"))
	for night in 5:
		Training.night(h, load("res://data/envs/shoreline.tres"), load("res://data/activities/scent_trail.tres"))
	assert_eq(h.stat(Types.Stat.KNACK), 50.0)
	assert_eq(h.affinity(Types.Affinity.TIDE), 42.0)
	assert_eq(Scoring.stars(h, r), 3)


func _pup() -> HearthlingData:
	var brine: DoughDef = load("res://data/doughs/brine_dough.tres")
	return Baking.bake(1, load("res://data/molds/pup.tres"), [brine, brine], [], load("res://data/seeds/null_heartseed.tres").duplicate(true))
