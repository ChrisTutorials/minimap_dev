class_name MinimapInteractionController
extends RefCounted
## Collapse/expand + non-authoritative waypoint interaction for the minimap.
##
## Holds only presentation state. It never mutates gameplay — a click produces
## a world-space [signal waypoint_requested] the game may ignore or use for a
## non-authoritative marker. Presentation-only per issue #588.

signal waypoint_requested(world_pos: Vector2)
signal collapsed_changed(collapsed: bool)

var collapsed: bool = false

## When true, clicks place a waypoint; when collapsed, clicks do nothing.
var interaction_enabled: bool = true


func toggle_collapsed() -> void:
	collapsed = not collapsed
	collapsed_changed.emit(collapsed)


## Convert a click in map-local pixels to a world position and emit a waypoint.
## [param map_local] is relative to the map frame origin; [param xform] maps it
## back to world space. Returns the world position (or null if disabled).
func handle_click(map_local: Vector2, xform: MinimapTransform) -> Vector2:
	if not interaction_enabled or collapsed or xform == null:
		return Vector2.ZERO
	var world_pos: Vector2 = xform.map_to_world(map_local)
	waypoint_requested.emit(world_pos)
	return world_pos


## Whether [param map_local] falls inside the map frame.
func is_inside(map_local: Vector2, xform: MinimapTransform) -> bool:
	if xform == null:
		return false
	return xform.map_rect.has_point(map_local)
