extends PanelContainer

const INPUT_RESPONSE = preload("res://input/input_response.tscn")

@export var max_lines_remembered := 30

@onready var scroll_container = $ScrollContainer
@onready var scrollbar = scroll_container.get_v_scroll_bar()
@onready var history_rows = $ScrollContainer/HistoryRows

var show_zebra := false
var zebra_margin : int = 0

func _ready() -> void:
	scrollbar.changed.connect(_handle_scrollbar_changed)
	zebra_margin = history_rows.get_theme_constant("separation") / 2

#### PUBLIC ####

func create_response_generated(response_text: String) -> void:
	var response = INPUT_RESPONSE.instantiate()
	_add_response_to_game(response)
	response.set_text(response_text)

func create_response_with_input(response_text: String, input_text: String) -> void:
	# create a new input-response instance to add to the history
	var input_response_instance = INPUT_RESPONSE.instantiate()
	_add_response_to_game(input_response_instance)
	input_response_instance.set_text(response_text, input_text)

#### PRIVATE #####

func _handle_scrollbar_changed() -> void:
	# automatically scroll scrollbar to 'current' position
	scroll_container.scroll_vertical = scrollbar.max_value

func _delete_history_beyond_limit() -> void:
	if history_rows.get_child_count() > max_lines_remembered:
		var rows_to_forget = history_rows.get_child_count() - max_lines_remembered
		for i in range(rows_to_forget):
			history_rows.get_child(i).queue_free()

func _add_response_to_game(response: Control) -> void:
	# add response to history
	history_rows.add_child(response)
	
	# handle this response's zebra striping
	response.zebra.get_theme_stylebox("panel").expand_margin_top = zebra_margin
	response.zebra.get_theme_stylebox("panel").expand_margin_bottom = zebra_margin
	if not show_zebra:
		response.zebra.hide()
	show_zebra = !show_zebra
	
	# check if the history exceeds some predefined length, if so: free oldest entries
	_delete_history_beyond_limit()

func _on_resized() -> void:
	# automatically scroll scrollbar to 'current' position after panel resize
	scroll_container.scroll_vertical = scrollbar.max_value
