class_name MinimapMarkerView
extends RefCounted
## Draws a single [MinimapMarker] onto a [CanvasItem] using a [MinimapTransform]
## and [MinimapTheme]. Pure presentation; reads only the neutral contract.
## See issue #588.

const Shape = MinimapTheme.Shape


## Draw [param marker] into [param ci] at its world->map position.
func draw(ci: CanvasItem, marker: MinimapMarker, xform: MinimapTransform, theme: MinimapTheme) -> void:
	if ci == null or marker == null or xform == null or theme == null:
		return
	var style: Dictionary = theme.marker_style(marker.kind)
	var color: Color = style.get("color", Color.WHITE)
	var shape: int = int(style.get("shape", Shape.DOT))
	var size: float = float(style.get("size", 4.0))
	var pos: Vector2 = xform.world_to_map(marker.position)

	# Faction tint overrides neutral color for faction-owned markers.
	if marker.faction_id >= 0 and marker.kind in [
		MinimapMarker.Kind.PAWN,
		MinimapMarker.Kind.FACTION_HOME,
		MinimapMarker.Kind.DEPOT,
		MinimapMarker.Kind.BUILDING,
	]:
		color = theme.faction_color(marker.faction_id)

	# Discovered-but-not-visible entities render at reduced detail/alpha.
	var alpha: float = 1.0
	if marker.kind == MinimapMarker.Kind.HOSTILE and not marker.visible:
		return  # hostile the player cannot see is not drawn (matches main view)
	if not marker.discovered:
		alpha = 0.55

	var draw_color := Color(color.r, color.g, color.b, color.a * alpha)

	match shape:
		Shape.DOT:
			ci.draw_circle(pos, size, draw_color)
		Shape.SQUARE:
			ci.draw_rect(Rect2(pos - Vector2(size, size), Vector2(size, size) * 2.0), draw_color)
		Shape.DIAMOND:
			_draw_diamond(ci, pos, size, draw_color)
		Shape.TRIANGLE:
			_draw_triangle(ci, pos, size, draw_color)
		Shape.HOUSE:
			_draw_house(ci, pos, size, draw_color)
		Shape.BARN:
			_draw_rect_outline(ci, pos, size, draw_color)
		Shape.STAR:
			_draw_star(ci, pos, size, draw_color)
		Shape.SKULL:
			ci.draw_circle(pos, size, draw_color)
		Shape.RING:
			ci.draw_arc(pos, size, 0.0, TAU, 16, draw_color, 1.5)
		_:
			ci.draw_circle(pos, size, draw_color)


func _draw_diamond(ci: CanvasItem, pos: Vector2, s: float, c: Color) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(0.0, -s),
		pos + Vector2(s, 0.0),
		pos + Vector2(0.0, s),
		pos + Vector2(-s, 0.0),
	])
	ci.draw_colored_polygon(pts, c)


func _draw_triangle(ci: CanvasItem, pos: Vector2, s: float, c: Color) -> void:
	# Apex points "up" on the map (north), marking the controlled player.
	var pts := PackedVector2Array([
		pos + Vector2(0.0, -s),
		pos + Vector2(s * 0.86, s * 0.5),
		pos + Vector2(-s * 0.86, s * 0.5),
	])
	ci.draw_colored_polygon(pts, c)


func _draw_house(ci: CanvasItem, pos: Vector2, s: float, c: Color) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-s, 0.0),
		pos + Vector2(s, 0.0),
		pos + Vector2(s, s),
		pos + Vector2(-s, s),
	])
	ci.draw_colored_polygon(pts, c)
	ci.draw_line(pos + Vector2(-s, 0.0), pos + Vector2(0.0, -s), c, 1.5)
	ci.draw_line(pos + Vector2(s, 0.0), pos + Vector2(0.0, -s), c, 1.5)


func _draw_rect_outline(ci: CanvasItem, pos: Vector2, s: float, c: Color) -> void:
	ci.draw_rect(Rect2(pos - Vector2(s, s), Vector2(s, s) * 2.0), c, false, 1.5)


func _draw_star(ci: CanvasItem, pos: Vector2, s: float, c: Color) -> void:
	var pts := PackedVector2Array()
	for i: int in range(10):
		var r := s if (i % 2 == 0) else s * 0.45
		var a := float(i) * (TAU / 10.0) - (TAU / 4.0)
		pts.append(pos + Vector2(cos(a), sin(a)) * r)
	ci.draw_colored_polygon(pts, c)
