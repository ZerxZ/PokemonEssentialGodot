@tool
extends Control

enum FolderState {NONE,SOURCE,OUTPUT}
enum FileType {PNG,JPG,JPEG,WEBP}

#region 节点
@onready var colorSpinBox:SpinBox = $%ColorSpinBox
@onready var sourceLineEdit:LineEdit = $%SourceLineEdit
@onready var outputLineEdit:LineEdit = $%OutputLineEdit
@onready var sourceFolderButton:Button = $%SouceFolderButton
@onready var convertButton:Button = $%ConvertButton
@onready var folderDialog:FileDialog = $%FolderDialog
@onready var formatOptionButton:OptionButton = $%FormatOptionButton
#endregion

#region 变量
@export var bgColorDifference :int = 3
var folderState:FolderState = FolderState.NONE
var fileType:FileType = FileType.PNG

var _sourceFolder:String = "";
var _outputFolder:String = ""
var sourceFolder:String : 
	get:
		return _sourceFolder;
	set(value):
		_sourceFolder = value;
		sourceLineEdit.text = _sourceFolder; 

var outputFolder:String: 
	get:
		return _outputFolder;
	set(value):
		_outputFolder = value;
		outputLineEdit.text = _outputFolder;

var thread:Thread;
# Called when the node enters the scene tree for the first time.
var mutex: Mutex;
#endregion

func _ready() -> void:
	colorSpinBox.value = bgColorDifference
	mutex = Mutex.new()
	thread = Thread.new()


#region 图片处理相关
func remove_backgroud(imageData:Image):
	var oldWidth = imageData.get_width();
	var oldHeight = imageData.get_height();
	var newData = 	Image.create(oldWidth, oldHeight, false, Image.FORMAT_RGBA8);
	var bgColor =  imageData.get_pixel(0,0)
	var colorCallble = get_color_diffence if bgColorDifference > 0 else equal_colors
	for x in range(oldWidth):
		for y in range(oldHeight):
			var oldColor = imageData.get_pixel(x,y)
			oldColor.to_html()
			if colorCallble.call(bgColor,oldColor):
				oldColor = Color(0,0,0,0)
			newData.set_pixel(x,y,oldColor)
	return newData;

func equal_colors(bgColor:Color, oldColor:Color):
	return bgColor == oldColor

func get_color_diffence(bgColor:Color, oldColor:Color):
	var resultColor:Color = bgColor - oldColor
	var result = get_color(resultColor * resultColor)
	return result < bgColorDifference

func get_color(color:Color):
	if color == Color(0,0,0,0):
		return 0
	var htmlColor = color.to_html()

	var red =htmlColor.substr(1,2).hex_to_int()
	var green = htmlColor.substr(3,2).hex_to_int()
	var blue =  htmlColor.substr(5,2).hex_to_int()
	var alpha =  htmlColor.substr(7,2).hex_to_int()
	return red + green + blue + alpha
				
				
func convert_image(files):
	for file in files:
		var ext = file.get_extension()
		match ext:
			"png","jpg","jpeg","webp":
				mutex.lock()
				var texture = ResourceLoader.load(sourceFolder + "/" + file) as CompressedTexture2D
				if (not is_instance_of(texture,Texture2D)) and (not is_instance_of(texture,Image)):
					mutex.unlock()
					continue;
				var image = texture.get_image() if is_instance_of(texture,Texture2D) else texture
				var newImage = remove_backgroud(image)
				var newPath = outputFolder + "/" + file.get_basename()
				save_image(newImage,newPath)
				mutex.unlock()

func save_image(image:Image, path:String) -> void:
	match fileType:
		FileType.PNG:
			image.save_png(path + ".png")
		FileType.JPG,FileType.JPEG:
			image.save_jpg(path + ".jpg",1)
		FileType.WEBP:
			image.save_webp(path + ".webp",false,1)
#endregion

#region 信号
func _on_spin_box_value_changed(value:float) -> void:
	bgColorDifference = value;

func pop_folder_dialog(state:FolderState) -> void:
	folderState = state
	folderDialog.popup_centered_ratio()

func _on_output_folder_button_button_down() -> void:
	pop_folder_dialog(FolderState.OUTPUT)


func _on_souce_folder_button_button_down() -> void:
	pop_folder_dialog(FolderState.SOURCE)

func _on_folder_dialog_dir_selected(dir:String) -> void:
	match folderState:
		FolderState.SOURCE:
			sourceFolder = dir
		FolderState.OUTPUT:
			outputFolder = dir
	folderState = FolderState.NONE


func _on_convert_button_button_down() -> void:
	if sourceFolder == "" or outputFolder == "":
		return
	if not DirAccess.dir_exists_absolute(sourceFolder):
		return
	var dir = DirAccess.open(sourceFolder)
	var files = dir.get_files()
	# print(files)
	if files.size() > 0:
		thread.start(convert_image.bind(files))


func _on_format_option_button_item_selected(index:int) -> void:
	fileType = FileType.values()[index]
#endregion
func _exit_tree():
		thread.wait_to_finish()