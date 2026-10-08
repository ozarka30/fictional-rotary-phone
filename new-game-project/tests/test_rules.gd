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
	assert_eq(req.egg.malleable_days, 3)
	assert_eq(req.intro_dialog.lines.size(), 6)  # defs are @tool so the editor keeps real values



func test_hatch_basic_egg() -> void:
	var egg: EggDef = load("res://data/eggs/basic_egg.tres")
	var h := Hatching.hatch(egg, load("res://data/families/pup.tres"), 7)
	assert_eq(h.uid, 7)
	assert_eq(h.malleable_days_left, 3)
	assert_eq(h.stats.size(), Types.Stat.size())
	assert_eq(h.potentials[Types.Stat.KNACK], 40.0)



func test_preview_leaves_original() -> void:
	var h := Hatching.hatch(load("res://data/eggs/basic_egg.tres"), load("res://data/families/pup.tres"), 1)
	var p := Shaping.preview(h, load("res://data/foods/brine_fish.tres"), load("res://data/pens/basic_pen.tres"))
	assert_eq(p.affinities[Types.Affinity.TIDE], 12.0)
	assert_false(h.affinities.has(Types.Affinity.TIDE))



## Hunter run: Brine fish on days 1-2 in the wash basin; once settled, Scent Trail on nights 4-5.
## Ends with C Knack (exactly 40) and D Tide (39): 3 stars.
func test_hunter_run_scores() -> void:
	var r: RequestDef = load("res://data/requests/hunter_tracker.tres")
	var h := Hatching.hatch(r.egg, load("res://data/families/pup.tres"), 1)
	var basin: PenDef = load("res://data/pens/wash_basin.tres")
	for night in 5:
		if night < 2:
			Shaping.give_food(h, load("res://data/foods/brine_fish.tres"), basin)
		Training.train(h, Training.YARDS[1].stats)  # no effect until settled
		assert_eq(Shaping.end_day(h, basin), night == 2)
	assert_eq(h.stats[Types.Stat.KNACK], 40.0)
	assert_eq(h.affinities[Types.Affinity.TIDE], 39.0)
	assert_eq(Scoring.stars(h, r), 3)
