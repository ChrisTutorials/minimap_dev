class_name MinimapSnapshot
extends RefCounted
## Presentation-agnostic minimap view built once per update by the game-side
## [MinimapPresenter] and consumed by the 2D and 3D rendering shells. No Godot
## Control / HUD knowledge lives here. See issue #588.

## Inclusive world bounds (same space as [MinimapMarker.position]); drives
## world-to-map normalization.
var world_bounds: Rect2 = Rect2()

## Stable id of the pawn the human controls, or -1.
var controlled_player_id: int = -1

## All known markers after visibility/discovery filtering.
var markers: Array[MinimapMarker] = []

## World-space point the playable camera is centered on.
var camera_center: Vector2 = Vector2.ZERO

## Unit world-space camera direction. The shell rotates the view wedge by this
## without rotating the map.
var camera_facing: Vector2 = Vector2(0.0, -1.0)

## Bumping [member revision] lets the shell detect unchanged data without
## comparing the whole array.
var revision: int = 0

func _init(
	p_world_bounds: Rect2 = Rect2(),
	p_controlled_player_id: int = -1,
) -> void:
	world_bounds = p_world_bounds
	controlled_player_id = p_controlled_player_id

func with_marker(marker: MinimapMarker) -> MinimapSnapshot:
	markers.append(marker)
	return self

## Controlled-player marker, or null.
func controlled_marker() -> MinimapMarker:
	for m: MinimapMarker in markers:
		if m.id == controlled_player_id:
			return m
	return null

## The accepted-task cue marker, or null.
func task_target_marker() -> MinimapMarker:
	for m: MinimapMarker in markers:
		if m.kind == MinimapMarker.Kind.TASK_TARGET:
			return m
	return null

func marker_by_id(p_id: int) -> MinimapMarker:
	for m: MinimapMarker in markers:
		if m.id == p_id:
			return m
	return null
