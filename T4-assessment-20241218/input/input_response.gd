extends MarginContainer

@onready var zebra = $Zebra
@onready var input_label : Label = $Rows/Input
@onready var response_label : RichTextLabel = $Rows/Response

func _ready() -> void:
	# set zebra-panel's expand margin equal to input-response's margins
	zebra.get_theme_stylebox("panel").expand_margin_left = self.get_theme_constant("margin_left")

func set_text(response: String, input: String = "") -> void:
	if input == "":
		input_label.queue_free()
	else:
		input_label.text = "> " + input
	
	response_label.text = response
