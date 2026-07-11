# Minimap (Godot / GDScript plugin)

A **reusable, presentation-only minimap shell** for Godot 4.x. It draws a
compact, north-up navigation overview from a single neutral data contract and
knows nothing about your simulation, ECS, or game-specific meaning.

This plugin is the *generic* half of a minimap vertical slice. The *game-specific*
half — the bridge that reads your authoritative world and projects it into the
neutral contract — lives in your game project and implements `MinimapDataSource`.

## Installation

1. Copy `addons/minimap/` into your Godot 4.x project (or symlink it from a
   shared plugins checkout).
2. Enable **Minimap** under `Project > Project Settings > Plugins`.
3. Implement `MinimapDataSource` in your game (see "Quick start" below) and feed
   the generic `MinimapPresenter` + `MinimapView`.

No autoload, node, or scene is added by the plugin — your game creates the
presenter/view and owns the wiring.

## Architecture

```
Authoritative world (Bevy ECS / GECS / your own sim)
        |  snapshots / events
        v
Game-side MinimapDataSource  (YOU implement this — e.g. BevySimMinimapSource)
        |  MinimapSnapshot (neutral, serializable)
        v
MinimapPresenter  (generic: drives bounded updates, injects camera, applies
        |                 visibility policy, emits snapshots)
        v
MinimapView  (generic GDScript shell: draws map, markers, camera wedge)
```

The plugin owns:

| Class | Role |
|-------|------|
| `MinimapSnapshot` | Neutral, presentation-agnostic world view (bounds, markers, camera). |
| `MinimapMarker` | One entry on the map (id, kind, position, faction, visibility flags). |
| `MinimapTransform` | Pure world<->map coordinate math (north-up, camera wedge). |
| `MinimapTheme` | Icon/color/shape selection and visual hierarchy. |
| `MinimapMarkerView` | Draws a single marker onto a `CanvasItem`. |
| `MinimapView` | `Control` rendering shell; consumes a snapshot, draws the map. |
| `MinimapInteractionController` | Collapse/expand + non-authoritative waypoint. |
| `MinimapDataSource` | Interface a game implements to feed the shell. |
| `MinimapPresenter` | Generic driver: collects from a source, injects camera, emits. |

The game owns:

- A `MinimapDataSource` implementation that queries the authoritative world
  (entity/building positions, faction ownership, depots/homes, controlled
  player, accepted-task target, discovery/visibility rules) and returns a
  `MinimapSnapshot`.
- The wiring that creates the `MinimapPresenter` + `MinimapView`, feeds the
  live camera center/facing and the controlled-player id each frame, and
  supplies an accepted-task-target provider.

## Contract rules

- **Presentation only.** The minimap never owns or mutates pawn, task, building,
  terrain, or faction truth. All facts arrive via `MinimapSnapshot`.
- **Neutral data.** `MinimapMarker` carries stable ids, kinds, positions, and
  visibility flags — not `Control` nodes, icons, or HUD layout.
- **Both 2D and 3D consume one shared contract.** Your 2D and 3D entrypoints
  feed the same `MinimapPresenter`/`MinimapView`; only the camera-facing vector
  (and the shell's draw target) differs.
- **Bounded updates.** The presenter rebuilds the snapshot on an interval, not
  every frame, unless you call `update_now()` in response to an event.

## Marker kinds

`MinimapMarker.Kind`: `CONTROLLED_PLAYER`, `PAWN`, `HOSTILE`, `FACTION_HOME`,
`DEPOT`, `BUILDING`, `TASK_TARGET`, `RESOURCE`. The shell maps each kind to a
shape/color/label via `MinimapTheme`; override the theme to restyle without
touching the shell.

## Quick start (in your game)

```gdscript
# 1. Implement MinimapDataSource (game-specific bridge).
var source := MyWorldMinimapSource.new()
source.configure(...)

# 2. Create the generic presenter + view (from this plugin).
var presenter := MinimapPresenter.new()
presenter.configure(source, world_region)
var view := MinimapView.new()
view.configure(Vector2(184, 184), world_bounds_rect, faction_colors)
presenter.snapshot_updated.connect(view.set_snapshot)
add_child(presenter)
add_child(view)

# 3. Each frame: push camera + controlled player.
presenter.set_camera(camera.global_position, camera_facing)
presenter.set_controlled_player(controlled_pawn.bevy_entity_id)
```

See the Thistletide integration (`BevySimMinimapSource` + `MinimapBootstrap`)
for a complete reference implementation against a Bevy ECS world.
