@tool
extends EditorPlugin

var dock


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/moemon_remove_bg/moe_mon_remove_bg_panel.tscn").instantiate()
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()

var bgColorDifference :int = 3
func removeBackground(imageData:Image):
	var oldWidth = imageData.get_width();
	var oldHeight = imageData.get_height();
	var newData = 	Image.create(oldWidth, oldHeight, false, Image.FORMAT_RGBA8);
	var bgColor =  imageData.get_pixel(0,0)
	var colorCallble = Callable(self,"getColorDifference" if bgColorDifference > 0 else "equalColor")
	for x in range(oldWidth):
		for y in range(oldHeight):
			var oldColor = imageData.get_pixel(x,y)
			oldColor.to_html()
			if colorCallble.call(bgColor,oldColor):
				oldColor = Color(0,0,0,0)
			newData.set_pixel(x,y,oldColor)
	return newData;

func equalColor(bgColor:Color, oldColor:Color):
	return bgColor == oldColor

func getColorDifference(bgColor:Color, oldColor:Color):
	var resultColor:Color = bgColor - oldColor
	resultColor = resultColor * resultColor
	return resultColor == Color(0,0,0,0)