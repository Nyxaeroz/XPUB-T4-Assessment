extends Control

@onready var player = $Player
@onready var command_processor = $CommandProcessor
@onready var room_manager = $RoomManager
@onready var game_info = $Background/MarginContainer/Rows/GameInfo
@onready var slide_manager = $SlideManager
@onready var slide_info = $Background/MarginContainer/Rows/SlideInfo

func _ready() -> void:
	game_info.create_response_generated(Types.wrap_system_text(
		"Welcome! This is a presentational build of Human Parser.\n\n" + 
		"Presenting can be [shake rate=20.0 level=5 connected=1]scary[/shake]. Luckily, there is a virtual Thijs here to help with the presentation. Please guide them to the aquarium!" +
		" [wave freq=5.0 amp=25.0 connected=1]Good luck![/wave]"
		))

	command_processor.slide_changed.connect(_handle_slide_changed)
	command_processor.start_presentation.connect(_handle_start_presentation)
	command_processor.pause_presentation.connect(_handle_pause_presentation)
	command_processor.resume_presentation.connect(_handle_resume_presentation)
	get_tree().get_root().size_changed.connect(slide_info.update_image_size_on_window_resize)
	
	#var cheatsheet = load("res://items//cheatsheet.tres")
	#player.take_item(cheatsheet)
	
	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	game_info.create_response_generated(starting_room_response)

# function for handling submitted text
func _on_input_text_submitted(new_text: String) -> void:
	# if the submission is empty, don't do anything
	if new_text.is_empty():
		return
	
	print("Thijs tries to " + new_text)
	
	# process user input in command_processor
	var response = command_processor.process_command(new_text)
	
	# let game_info handle the response (text styling and showing etc)
	game_info.create_response_with_input(response, new_text)
	
func _handle_slide_changed(slide_name: String) -> void:
	var new_slide = slide_manager.get_node(slide_name)
	slide_info.handle_slide_changed(new_slide)

func _handle_start_presentation() -> void:
	slide_info.visible = true
	slide_info.make_slide_visible()

func _handle_pause_presentation() -> void:
	slide_info.make_slide_invisible()
	await get_tree().create_timer(1).timeout # this should be a signal emitted by slide_info when make_slide_invisible is completed
	slide_info.visible = false

func _handle_resume_presentation() -> void:
	slide_info.visible = true
	slide_info.make_slide_visible() 
	
