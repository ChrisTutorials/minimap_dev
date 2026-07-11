class_name MinimapTheme
extends RefCounted
## Presentation styling for the minimap shell. Owns icon selection, color, and
## visual hierarchy — never authoritative data. GDScript-side only (#588).
##
## [member faction_colors] should be injected from the spawner's canonical
## faction palette so the minimap matches the rest of the game. A neutral
## fallback palette is provided so the shell is usable before injection.

## Per-faction colors, indexed by faction id. Injected from the world spawner.
var faction_colors: Array[Color] = []

## Fallback palette used when [member faction_colors] is empty/sparse.
const FALLBACK_FACTION_COLORS: Array[Color] = [
	Color(0.85, 0.55, 0.30),  # faction 0 — warm orange
	Color(0.40, 0.65, 0.95),  # faction 1 — blue
	Color(0.55, 0.80, 0.40),  # faction 2 — green
	Color(0.85, 0.45, 0.70),  # faction 3 — magenta
	Color(0.75, 0.75, 0.40),  # faction 4 — olive
]

const CONTROLLED_COLOR := Color(1.0, 1.0, 1.0)
const HOSTILE_COLOR := Color(0.90, 0.25, 0.25)
const DEPOT_COLOR := Color(0.58, 0.48, 0.32)
const HOME_COLOR := Color(0.55, 0.50, 0.28)
const BUILDING_COLOR := Color(0.70, 0.70, 0.75)
const TASK_COLOR := Color(0.45, 0.58, 0.90)
const RESOURCE_COLOR := Color(0.95, 0.85, 0.40)


## Marker geometry the shell draws. [member shape] is a hint, not a Godot type.
enum Shape { DOT, TRIANGLE, SQUARE, DIAMOND, HOUSE, BARN, STAR, SKULL, RING }


func _init(p_faction_colors: Array[Color] = []) -> void:
	faction_colors = p_faction_colors


func faction_color(faction_id: int) -> Color:
	if faction_id >= 0 and faction_id < faction_colors.size():
		return faction_colors[faction_id]
	if faction_id >= 0 and faction_id < FALLBACK_FACTION_COLORS.size():
		return FALLBACK_FACTION_COLORS[faction_id]
	return Color(0.7, 0.7, 0.7)


## Returns the drawing contract for a marker kind: { color, shape, size, label }.
func marker_style(kind: int) -> Dictionary:
	match kind:
		MinimapMarker.Kind.CONTROLLED_PLAYER:
			return { "color": CONTROLLED_COLOR, "shape": Shape.TRIANGLE, "size": 7.0, "label": "You" }
		MinimapMarker.Kind.PAWN:
			return { "color": Color(0.85, 0.85, 0.85), "shape": Shape.DOT, "size": 3.5, "label": "" }
		MinimapMarker.Kind.HOSTILE:
			return { "color": HOSTILE_COLOR, "shape": Shape.SKULL, "size": 5.0, "label": "Hostile" }
		MinimapMarker.Kind.FACTION_HOME:
			return { "color": HOME_COLOR, "shape": Shape.HOUSE, "size": 8.0, "label": "Home" }
		MinimapMarker.Kind.DEPOT:
			return { "color": DEPOT_COLOR, "shape": Shape.BARN, "size": 8.0, "label": "Depot" }
		MinimapMarker.Kind.BUILDING:
			return { "color": BUILDING_COLOR, "shape": Shape.SQUARE, "size": 6.0, "label": "Building" }
		MinimapMarker.Kind.TASK_TARGET:
			return { "color": TASK_COLOR, "shape": Shape.STAR, "size": 7.0, "label": "Task" }
		MinimapMarker.Kind.RESOURCE:
			return { "color": RESOURCE_COLOR, "shape": Shape.DIAMOND, "size": 4.5, "label": "Resource" }
		_:
			return { "color": Color(0.7, 0.7, 0.7), "shape": Shape.DOT, "size": 3.5, "label": "" }


## Background fill for the map body.
func background_color() -> Color:
	return Color(0.12, 0.15, 0.11, 0.85)


## Border/accent color for the map frame.
func frame_color() -> Color:
	return Color(0.35, 0.40, 0.32, 0.9)
