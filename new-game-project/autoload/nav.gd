extends Node
## Page switching. Every area of the shop is its own scene; the main page is home.

const PAGES := {
	&"home": "res://scenes/ui/main_page.tscn",
	&"front_desk": "res://scenes/ui/front_desk_page.tscn",
	&"pens": "res://scenes/ui/pens_page.tscn",
	&"training_yard": "res://scenes/ui/training_yard_page.tscn",
	&"market": "res://scenes/ui/market_page.tscn",
	&"ledger": "res://scenes/ui/ledger_page.tscn",
}

var note := ""  ## the morning summary; every page's HUD shows it for the day


func go(page: StringName) -> void:
	if PAGES.has(page):
		get_tree().change_scene_to_file.call_deferred(PAGES[page])


func home() -> void:
	go(&"home")


func reload() -> void:
	get_tree().reload_current_scene.call_deferred()
