@tool
extends EditorPlugin

var dock:MoemonRemoveBGPanel


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/moemon_remove_bg/moe_mon_remove_bg_panel.tscn").instantiate() as MoemonRemoveBGPanel
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.

func _exit_tree() -> void:
	dock.thread.wait_to_finish()
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
