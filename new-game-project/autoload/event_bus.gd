extends Node
@warning_ignore_start("unused_signal")  # signals are emitted from other scripts
## Cross-system signals only. No state lives here.
## Params are loosely typed until the def/state classes exist.

# Time and day
signal sleep_requested()
signal day_ending(day: int)
signal day_started(day: int)
signal overnight_report_ready(report: Dictionary)
signal clock_changed(minutes: int)

# Resources
signal mana_changed(free: int, capacity: int)
signal coin_changed(amount: int)
signal materials_changed(material_id: StringName, amount: int)

# Tasks
signal task_queued(task: Resource)
signal task_rejected(task: Resource, reason: String)
signal task_started(task: Resource, worker: Node)
signal task_completed(task: Resource, worker: Node)

# Avatars and Hearthlings
signal avatar_formed(avatar: Node)
signal egg_received(egg: Resource)
signal hearthling_hatched(h: Resource)
signal hearthling_changed(h: Resource)
signal hearthling_stabilized(h: Resource)

# Customers and requests
signal customer_arrived(customer: Node)
signal customer_left(customer: Node)
signal request_received(req: Resource)
signal request_completed(req: Resource, grade: int)

# Dialog and UI
signal dialog_requested(dialog: Resource)
signal dialog_finished(dialog_id: StringName)
signal entity_selected(entity: Node)
signal panel_opened(panel_id: StringName)
signal panel_closed(panel_id: StringName)

# Tutorial
signal station_unlocked(station_id: StringName)
signal tutorial_beat_changed(beat: int)
