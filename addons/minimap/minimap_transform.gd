class_name MinimapTransform
extends RefCounted
## Pure world-to-map coordinate math; no Node, no drawing.
##
## The map stays north-up even though the camera is a fixed 3/4 angle
## (#515/#517). World coordinates normalize against [member world_bounds] and
## the resulting [0..1] factors map into [member map_rect]. Both the 2D and 3D
## shells share this transform. See issue #588.

## Inclusive world rectangle the map represents.
var world_bounds: Rect2 = Rect2()

## On-screen rectangle (control-local pixels) the map is drawn into.
var map_rect: Rect2 = Rect2()

## World direction treated as up on the map; defaults to -Y. Override if the
## project's canonical up differs.
var north: Vector2 = Vector2(0.0, -1.0)

func _init(p_world_bounds: Rect2 = Rect2(), p_map_rect: Rect2 = Rect2()) -> void:
	world_bounds = p_world_bounds
	map_rect = p_map_rect

## Normalize a world position to [0..1] within [member world_bounds], clamping
## out-of-bounds positions to the edge.
func world_to_normalized(world_pos: Vector2) -> Vector2:
	if world_bounds.size.x <= 0.0 or world_bounds.size.y <= 0.0:
		return Vector2.ZERO
	var fx: float = (world_pos.x - world_bounds.position.x) / world_bounds.size.x
	var fy: float = (world_pos.y - world_bounds.position.y) / world_bounds.size.y
	return Vector2(clampf(fx, 0.0, 1.0), clampf(fy, 0.0, 1.0))

## Map a normalized [0..1] factor back to world space.
func normalized_to_world(factor: Vector2) -> Vector2:
	return Vector2(
		world_bounds.position.x + factor.x * world_bounds.size.x,
		world_bounds.position.y + factor.y * world_bounds.size.y,
	)

## World position to on-screen map pixel position.
func world_to_map(world_pos: Vector2) -> Vector2:
	var f: Vector2 = world_to_normalized(world_pos)
	return Vector2(
		map_rect.position.x + f.x * map_rect.size.x,
		map_rect.position.y + f.y * map_rect.size.y,
	)

## On-screen map pixel position to world position (inverse of [method world_to_map]).
func map_to_world(map_pos: Vector2) -> Vector2:
	if map_rect.size.x <= 0.0 or map_rect.size.y <= 0.0:
		return Vector2.ZERO
	var fx: float = (map_pos.x - map_rect.position.x) / map_rect.size.x
	var fy: float = (map_pos.y - map_rect.position.y) / map_rect.size.y
	return normalized_to_world(Vector2(fx, fy))

## Angle in radians of [param world_facing] relative to [member north]; rotates
## the camera wedge while the map stays north-up.
func facing_angle(world_facing: Vector2) -> float:
	if world_facing == Vector2.ZERO:
		return 0.0
	var n: Vector2 = north
	if n == Vector2.ZERO:
		n = Vector2(0.0, -1.0)
	return n.angle_to(world_facing)

## Three points (apex plus two corners) for a camera wedge centered on
## [param center_map] and pointing along [param world_facing].
func camera_wedge_points(center_map: Vector2, world_facing: Vector2, half_angle: float, length: float) -> PackedVector2Array:
	var a: float = facing_angle(world_facing)
	var apex: Vector2 = center_map
	var left: Vector2 = apex + Vector2(cos(a - half_angle), sin(a - half_angle)) * length
	var right: Vector2 = apex + Vector2(cos(a + half_angle), sin(a + half_angle)) * length
	return PackedVector2Array([apex, left, right])

## Whether a world position falls inside [member world_bounds].
func contains_world(world_pos: Vector2) -> bool:
	return world_bounds.has_point(world_pos)
