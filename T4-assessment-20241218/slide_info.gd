extends PanelContainer

@onready var room_name = $MarginContainer/Rows/RoomName
@onready var room_desc = $MarginContainer/Rows/RoomDescription
@onready var gallery = $MarginContainer/Rows/Gallery
@onready var room_image_1 = $MarginContainer/Rows/Gallery/RoomImage1
@onready var room_image_2 = $MarginContainer/Rows/Gallery/RoomImage2
@onready var room_image_3 = $MarginContainer/Rows/Gallery/RoomImage3

var min_container_height_without_img : int = 60
var image_size : int = 240

var cur_slide = null

func _ready() -> void:
	room_name.visible = false
	room_desc.visible = false
	gallery.visible = false

func make_slide_visible() -> void:
	var tween = create_tween()
	tween.tween_property(self, "custom_minimum_size", Vector2(0,min_container_height_without_img + gallery.size.y), 0.5).from(Vector2.ZERO)
	tween.tween_callback(func():
		room_name.visible = true
		room_desc.visible = true
		gallery.visible = true
	)
	tween.tween_property(room_name, "visible_ratio", 1.0, 0.3).from(0.0)
	tween.parallel().tween_property(room_desc, "visible_ratio", 1.0, 0.3).from(0.0)
	tween.parallel().tween_property(room_image_1, "modulate:a", 1.0, 0.8).from(0.0)
	tween.parallel().tween_property(room_image_2, "modulate:a", 1.0, 0.8).from(0.0)
	tween.parallel().tween_property(room_image_3, "modulate:a", 1.0, 0.8).from(0.0)

func make_slide_invisible() -> void:
	var tween = create_tween()
	tween.tween_property(room_image_1, "modulate:a", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_image_2, "modulate:a", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_image_3, "modulate:a", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_desc, "visible_ratio", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_name, "visible_ratio", 0.0, 0.3).from(1.0)
	tween.tween_callback(func():
		room_name.visible = false
		room_desc.visible = false
		gallery.visible = false
	)
	tween.tween_property(self, "custom_minimum_size", Vector2.ZERO, 0.5).from(self.size)

func handle_slide_changed(new_room: GameRoom) -> void:
	var gallery_height = 0
	if new_room.room_images.size() > 0:
		gallery_height = image_size
	
	var tween = create_tween()
	tween.tween_property(room_image_1, "modulate:a", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_image_2, "modulate:a", 0.0, 0.3).from(1.0)
	tween.parallel().tween_property(room_image_3, "modulate:a", 0.0, 0.3).from(1.0)
	tween.tween_property(room_desc, "visible_ratio", 0.0, 0.3).from(1.0)
	tween.tween_property(room_name, "visible_ratio", 0.0, 0.3).from(1.0)
	tween.tween_property(gallery, "custom_minimum_size", Vector2(0,gallery_height), 0.5).from(gallery.size)	
	tween.tween_callback(func():
		room_name.text = "[center]%s[/center]" % new_room.room_name
		room_desc.text = "[center]%s[/center]" % new_room.room_description
		update_gallery(new_room.room_images)
	)
	tween.tween_property(room_name, "visible_ratio", 1.0, 0.3).from(0.0)
	tween.parallel().tween_property(room_desc, "visible_ratio", 1.0, 0.3).from(0.0)
	tween.parallel().tween_property(room_image_1, "modulate:a", 1.0, 0.8).from(0.0)
	tween.parallel().tween_property(room_image_2, "modulate:a", 1.0, 0.8).from(0.0)
	tween.parallel().tween_property(room_image_3, "modulate:a", 1.0, 0.8).from(0.0)
	await tween.finished

func update_gallery(images: Array[Texture]) -> void:
	if images.size() <= 0:
		return
	elif images.size() == 1:
		room_image_1.visible = true
		room_image_2.visible = false
		room_image_3.visible = false
		room_image_1.texture = images[0]
	elif images.size() == 2:
		room_image_1.visible = true
		room_image_2.visible = true
		room_image_3.visible = false
		room_image_1.texture = images[0]
		room_image_2.texture = images[1]
	elif images.size() == 3:
		room_image_1.visible = true
		room_image_2.visible = true
		room_image_3.visible = true
		room_image_1.texture = images[0]
		room_image_2.texture = images[1]
		room_image_3.texture = images[2]
		pass
	else:
		printerr("Too many images")
	
func update_image_size_on_window_resize():
	image_size = get_viewport().get_visible_rect().size.y / 3
	
