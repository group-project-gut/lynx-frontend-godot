extends Node

func _ready():
	self.get_node("CodeEditor").visible = false
	self.get_node("CreateAgent").visible = false

func _on_access_code_editor_button_up():
	self.get_node("CodeEditor").visible = !self.get_node("CodeEditor").visible
	self.get_node("CreateAgent").visible = !self.get_node("CreateAgent").visible
