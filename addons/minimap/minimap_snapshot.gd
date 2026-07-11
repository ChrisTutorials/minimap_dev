class_name MinimapSnapshot
extends RefCounted
## Neutral, presentation-agnostic view of the world for the minimap.
##
## Built once per update by the game-side [MinimapPresenter] from the Bevy ECS
## world (plus Thistletide-specific visibility/faction/landmark/task rules) and
## consumed identically by both the 2D and 3D minimap rendering shells. No
## Godot Control / HUD knowledge lives here. See issue #588.

## Inclusive world bounds the map covers, in the same coordinate space as
## [MinimapMarker.position]. Drives the world->map normalization.
var world_bounds: Rect2 = Rect2()

## Stable id of the pawn the human currently controls, or -1.
var controlled_player_id: int = -1

## All known markers after visibility/discovery filtering.
var markers: Array[MinimapMarker] = []

## World-space camera focus (the point the playable camera is centered on).
var camera_center: Vector2 = Vector2.ZERO

## Unit world-space direction the camera is facing (north-up is +Y or the
## project's canonical "up"). The shell rotates the view wedge by this without
## rotating the rest of the map.
var camera_facing: Vector2 = Vector2(0.0, -1.0)

## Bumping [member revision] lets the shell cheaply detect "same data, no
## redraw needed" vs a genuine change without comparing the whole array.
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


## Returns the controlled-player marker, or null.
func controlled_marker() -> MinimapMarker:
	for m: MinimapMarker in markers:
		if m.id == controlled_player_id:
			return m
	return null


## Returns the single accepted-task cue marker, or null.
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
