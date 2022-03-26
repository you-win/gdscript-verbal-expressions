extends CanvasLayer

const VerbalExpressions = preload("res://addons/verbal-expressions/verbal_expressions.gd")

const Selector := {
	"SEARCH": "Search",
	"REPLACE": "Replace"
}

const SCRIPT_COMPILE_ERROR := "Error occurred while compiling script"
const COMPILE_SUCCESS := "Compiled successfully"

const NO_MATCHES := "No matches found"

onready var ve_te: TextEdit = $PanelContainer/VSplitContainer/HSplitContainer/VE/TextEdit

onready var search_vbox: VBoxContainer = $PanelContainer/VSplitContainer/HSplitContainer/Omni/Search
onready var search_te: TextEdit = $PanelContainer/VSplitContainer/HSplitContainer/Omni/Search/TextEdit

onready var replace_vbox: VBoxContainer = $PanelContainer/VSplitContainer/HSplitContainer/Omni/Replace
onready var replace_te: TextEdit = $PanelContainer/VSplitContainer/HSplitContainer/Omni/Replace/TextEdit
onready var with_te: TextEdit = $PanelContainer/VSplitContainer/HSplitContainer/Omni/Replace/TextEdit2

onready var status_te: TextEdit = $PanelContainer/VSplitContainer/Options/Status/TextEdit

onready var raw_te: TextEdit = $PanelContainer/VSplitContainer/Options/VSplitContainer/RawRegex/TextEdit

onready var compile: Button = $PanelContainer/VSplitContainer/Options/VSplitContainer/HSplitContainer/VBoxContainer/Compile
onready var run: Button = $PanelContainer/VSplitContainer/Options/VSplitContainer/HSplitContainer/VBoxContainer/Run

onready var selector: CheckButton = $PanelContainer/VSplitContainer/Options/VSplitContainer/HSplitContainer/VBoxContainer2/Selector
onready var about: Button = $PanelContainer/VSplitContainer/Options/VSplitContainer/HSplitContainer/VBoxContainer2/About
onready var about_view: PanelContainer = $About
onready var about_view_button: Button = $About/VBoxContainer/About

var is_search := true

var ve: VerbalExpressions

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	compile.connect("pressed", self, "_on_compile")
	run.connect("pressed", self, "_on_run")
	
	selector.connect("toggled", self, "_on_selector")
	
	about.connect("pressed", self, "_on_about")
	about_view_button.connect("pressed", self, "_on_about")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_compile() -> bool:
	var script := _create_compile_script(ve_te.text)
	if script == null:
		status_te.text = SCRIPT_COMPILE_ERROR
		return false
	
	var compiler = script.new()
	compiler.compile()
	
	ve = compiler.ve
	
	status_te.text = COMPILE_SUCCESS
	raw_te.text = ve.get_pattern()
	
	return true

func _on_run() -> void:
	if ve == null:
		if not _on_compile():
			return
	
	if is_search:
		var res: RegExMatch = ve.search(search_te.text)
		if res == null:
			status_te.text = NO_MATCHES
		else:
			status_te.text = res.get_string()
	else:
		status_te.text = ve.sub(replace_te.text, with_te.text)

func _on_selector(state: bool) -> void:
	is_search = state
	
	if is_search:
		selector.text = Selector.SEARCH
		search_vbox.show()
		replace_vbox.hide()
	else:
		selector.text = Selector.REPLACE
		search_vbox.hide()
		replace_vbox.show()

func _on_about() -> void:
	about_view.visible = not about_view.visible

###############################################################################
# Private functions                                                           #
###############################################################################

static func _create_compile_script(text: String) -> GDScript:
	var r := GDScript.new()
	
	var sc := ""
	
	sc = _add_line(sc, "var ve = load('res://addons/verbal-expressions/verbal_expressions.gd').new()")
	
	sc = _add_line(sc, "func compile():")
	var split := text.split("\n")
	for line in split:
		sc = _add_line(sc, "\t%s" % line)
	
	r.source_code = sc
	if r.reload() != OK:
		return null
	
	return r

static func _add_line(source: String, text: String) -> String:
	return source + "%s\n" % text

###############################################################################
# Public functions                                                            #
###############################################################################
