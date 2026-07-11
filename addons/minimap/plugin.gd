class_name MinimapPlugin
extends EditorPlugin
## Minimal entry script so Godot recognizes the Minimap addon as a plugin.
##
## The plugin ships only runtime classes (MinimapView, MinimapSnapshot,
## MinimapTransform, etc.) and a data-source interface — there is no editor
## UI to install. Enable the plugin in Project Settings > Plugins to register
## its global classes; gameplay code wires a concrete MinimapDataSource
## (game-specific) to the generic MinimapPresenter/MinimapView. See README.md.
