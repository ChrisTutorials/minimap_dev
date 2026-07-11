class_name MinimapDataSource
extends RefCounted
## Seam between the authoritative world and the minimap's neutral contract.
##
## Implementations project world state into a [MinimapSnapshot]. The minimap
## shell depends only on this interface, so the reusable shell never learns
## about Bevy, ECS, or Thistletide specifics. The first real implementation is
## [BevySimMinimapSource] (game-local, issue #588). A plugin-extracted generic
## backend would implement the same interface later.

## Build the current snapshot for the given controlled pawn id.
func collect(controlled_player_id: int) -> MinimapSnapshot:
	push_error("MinimapDataSource.collect() must be implemented by a subclass.")
	return MinimapSnapshot.new()
