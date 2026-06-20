@tool
extends VBoxContainer
## STRIX Asset Hub - Dock UI Controller
## Handles user interactions for selecting, exporting, and importing asset packages.
## Coordinates with the Engine Facade to execute packaging workflows while providing
## real-time visual feedback via progress bars, file trees, and status dialogs.

const ITCH_URL: String = "https://strix-owl.itch.io/"
const KOFI_URL: String = "https://ko-fi.com/strix_owl"
const PackagerEngine: Script = preload("./asset_packer_engine.gd")

var engine: RefCounted = PackagerEngine.new()

var _file_dialog: EditorFileDialog
var _save_dialog: EditorFileDialog
var _import_dialog: EditorFileDialog
var _success_dialog: AcceptDialog

var _detected_autoloads: Dictionary = {}
var _selected_path: String = ""
var _files_to_pack: Array[String] = []
var _missing_files: Array[String] = []

@onready var _btn_select: Button = $BtnSelectFolder
@onready var _btn_export: Button = $BtnExport
@onready var _btn_import: Button = $BtnImport
@onready var _btn_about: Button = $HeaderBox/BtnAbout
@onready var _lbl_path: Label = $LblPath
@onready var _progress_bar: ProgressBar = $ProgressBar
@onready var _file_tree: Tree = $FileTree
@onready var _logo: TextureRect = $HeaderBox/TexLogo
@onready var _warning_dialog: AcceptDialog = $WarningDialog
@onready var _about_dialog: AcceptDialog = $AboutDialog
@onready var _about_text: RichTextLabel = $AboutDialog/AboutText

func _ready() -> void:
	if not is_node_ready(): return
	_btn_export.disabled = true
	_setup_signal_connections()
	_setup_dialogs()
	_update_theme_style()

func _setup_signal_connections() -> void:
	_btn_select.pressed.connect(_on_select_pressed)
	_btn_export.pressed.connect(_on_export_pressed)
	_btn_import.pressed.connect(_on_import_pressed)
	_btn_about.pressed.connect(_about_dialog.popup_centered)
	_about_text.meta_clicked.connect(_on_meta_clicked)

	if not engine.progress_updated.is_connected(_on_engine_progress):
		engine.progress_updated.connect(_on_engine_progress)
	if not engine.task_finished.is_connected(_on_engine_finished):
		engine.task_finished.connect(_on_engine_finished)
	if not engine.import_finished.is_connected(_on_engine_import_finished):
		engine.import_finished.connect(_on_engine_import_finished)
	if not engine.error_occurred.is_connected(_on_engine_error):
		engine.error_occurred.connect(_on_engine_error)

func _setup_dialogs() -> void:
	for child in get_children():
		if (child is EditorFileDialog or child is AcceptDialog) and child.name.begins_with("Strix"):
			child.queue_free()

	_file_dialog = _create_file_dialog(EditorFileDialog.FILE_MODE_OPEN_ANY, EditorFileDialog.ACCESS_RESOURCES, _on_path_selected)
	_file_dialog.name = "StrixSourceDialog"
	add_child(_file_dialog)

	_save_dialog = _create_file_dialog(EditorFileDialog.FILE_MODE_SAVE_FILE, EditorFileDialog.ACCESS_FILESYSTEM, _on_save_selected)
	_save_dialog.name = "StrixSaveDialog"
	_save_dialog.add_filter("*.zip", "ZIP Archive")
	add_child(_save_dialog)

	_import_dialog = _create_file_dialog(EditorFileDialog.FILE_MODE_OPEN_FILE, EditorFileDialog.ACCESS_FILESYSTEM, _on_import_selected)
	_import_dialog.name = "StrixImportDialog"
	_import_dialog.add_filter("*.zip", "STRIX Package")
	add_child(_import_dialog)

	_success_dialog = AcceptDialog.new()
	_success_dialog.name = "StrixSuccessDialog"
	_success_dialog.title = "Operation Complete"
	add_child(_success_dialog)

func _create_file_dialog(mode: EditorFileDialog.FileMode, access: EditorFileDialog.Access, on_selected: Callable) -> EditorFileDialog:
	var dialog: EditorFileDialog = EditorFileDialog.new()
	dialog.file_mode = mode
	dialog.access = access
	dialog.file_selected.connect(on_selected)
	dialog.dir_selected.connect(on_selected)
	return dialog

func _on_path_selected(path: String) -> void:
	_selected_path = path
	_lbl_path.text = "Source: " + path
	_btn_export.disabled = true

	var base_files: Array[String] = []
	if DirAccess.dir_exists_absolute(path):
		base_files = engine.get_all_files_in_dir(path)
	else:
		base_files.append(path)

	var results: Dictionary = await engine.collect_dependencies(base_files, get_tree())
	
	# Safe assignment: assign() handles Array[Variant] → Array[String] conversion natively
	_files_to_pack.assign(results.get("to_pack", []))
	_missing_files.assign(results.get("missing", []))
	_detected_autoloads = results.get("autoloads", {}) as Dictionary

	var display_list: Array[String] = _files_to_pack.duplicate()
	for missing in _missing_files:
		if not display_list.has(missing):
			display_list.append(missing)

	if display_list.is_empty():
		_warning_dialog.dialog_text = "No valid files or dependencies found. Please check your selection."
		_warning_dialog.popup_centered()
		_file_tree.clear()
		return

	_build_file_tree(display_list)
	_btn_export.disabled = _files_to_pack.is_empty()

func _on_save_selected(save_path: String) -> void:
	_progress_bar.visible = true
	_progress_bar.value = 0
	engine.create_zip(save_path, _files_to_pack, _detected_autoloads, get_tree())

func _on_import_selected(zip_path: String) -> void:
	_progress_bar.visible = true
	_progress_bar.value = 0
	_btn_import.disabled = true
	engine.import_zip(zip_path, get_tree())

func _on_engine_progress(current: int, total: int) -> void:
	_progress_bar.max_value = total
	_progress_bar.value = current

func _on_engine_finished(success_count: int, total_count: int, save_path: String) -> void:
	_progress_bar.visible = false
	if save_path.is_empty():
		_show_status_dialog("Export Failed", "❌ Failed to create ZIP archive.\nCheck folder permissions and disk space.")
		return

	var message: String = "✅ Packed %d / %d files\n📁 Saved: %s" % [success_count, total_count, save_path]
	if not _missing_files.is_empty():
		message += "\n\n⚠️ %d missing dependencies detected. Review the file tree for details." % _missing_files.size()

	_show_status_dialog("Export Complete", message)
	OS.shell_open(save_path.get_base_dir())

func _on_engine_import_finished(success: bool, message: String) -> void:
	_progress_bar.visible = false
	_btn_import.disabled = false
	_show_status_dialog("Import Status", message)

func _on_engine_error(code: int, message: String) -> void:
	push_error("[STRIX Error %d] %s" % [code, message])
	_show_status_dialog("Operation Failed", "❌ Error %d: %s\n\nCheck the Output console for details." % [code, message])
	_progress_bar.visible = false
	_btn_import.disabled = false

func _show_status_dialog(title: String, content: String) -> void:
	_success_dialog.title = title
	_success_dialog.dialog_text = content
	_success_dialog.popup_centered()

func _build_file_tree(file_paths: Array[String]) -> void:
	if not is_instance_valid(_file_tree): return

	_file_tree.clear()
	var root: TreeItem = _file_tree.create_item()
	root.set_text(0, "📦 Package Contents (%d items)" % file_paths.size())

	var folder_cache: Dictionary = {}
	const MISSING_COLOR: Color = Color(1.0, 0.4, 0.4)

	for file_path in file_paths:
		var relative_path: String = file_path.trim_prefix("res://")
		var segments: PackedStringArray = relative_path.split("/")
		var parent: TreeItem = root
		var accumulated_path: String = ""

		for i in range(segments.size()):
			var segment: String = segments[i]
			var is_leaf: bool = (i == segments.size() - 1)

			if is_leaf:
				var item: TreeItem = _file_tree.create_item(parent)
				if _missing_files.has(file_path):
					item.set_text(0, "⚠️ [MISSING] " + segment)
					item.set_custom_color(0, MISSING_COLOR)
					var ancestor: TreeItem = parent
					while ancestor and ancestor != root:
						ancestor.set_custom_color(0, MISSING_COLOR)
						ancestor.collapsed = false
						ancestor = ancestor.get_parent()
				else:
					item.set_text(0, "📄 " + segment)
			else:
				accumulated_path += segment + "/"
				if not folder_cache.has(accumulated_path):
					var folder_item: TreeItem = _file_tree.create_item(parent)
					folder_item.set_text(0, "📁 " + segment)
					folder_item.collapsed = true
					folder_cache[accumulated_path] = folder_item
				parent = folder_cache[accumulated_path]

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme_style()

func _update_theme_style() -> void:
	if not is_inside_tree() or not is_instance_valid(_logo): return
	var base_color: Color = EditorInterface.get_editor_settings().get_setting("interface/theme/base_color")
	_logo.self_modulate = Color(0.9, 0.9, 0.9) if base_color.v < 0.5 else Color(0.1, 0.1, 0.1)

func _on_meta_clicked(meta: Variant) -> void:
	var links: Dictionary = {"itch": ITCH_URL, "kofi": KOFI_URL}
	var key: String = str(meta)
	if links.has(key):
		OS.shell_open(links[key])

func _on_select_pressed() -> void: if _file_dialog: _file_dialog.popup_file_dialog()
func _on_export_pressed() -> void: if _save_dialog: _save_dialog.popup_file_dialog()
func _on_import_pressed() -> void: if _import_dialog: _import_dialog.popup_file_dialog()