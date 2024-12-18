extends Node

signal slide_changed(new_room)
signal start_presentation
signal pause_presentation
signal resume_presentation
var presenting = false
var current_slide = ""

var current_room = null
var player = null
	
func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)
	
func process_command(input: String) -> String:
	var words = input.split(" ", false)
	if words.size() == 0:
		return "Error parsing 0-length input"
	var first_word = words[0].to_lower()
	
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()
	
	match first_word:
		"go": 
			return go(second_word)
		"take":
			return take(second_word)
		"drop":
			return drop(second_word)
		"use":
			return use(second_word)
		"talk":
			return talk(second_word)
		"read":
			return read(second_word)
		"give":
			return give(second_word)
		"show":
			return show(second_word)
		"start":
			return start(second_word)
		"pause":
			return pause()
		"resume":
			return resume()
		"slides":
			return show_slides()
		"inventory":
			return inventory()
		"help":
			return help()
		"hide":
			return hide()
		"scream":
			return scream()
		"meditate":
			return meditate()
		"relax":
			return relax()
		
		
	return Types.wrap_system_text("Thijs doesn't understand any of this!")
	
func go(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Go where?") 
	
	if current_room.exits.keys().has(second_word):
		var exit = current_room.exits[second_word]
		if exit.is_locked:
			return "The way to the %s is currently %s" % [Types.wrap_location_text(second_word), Types.wrap_system_text("locked")] + "\nThijs starts to [shake rate=20 level-5 connected=1]panic[/shake], they'll be late."
		var change_room_response = change_room(exit.get_other_room(current_room))
		#return "\n".join(PackedStringArray(["You go to the %s" % second_word, change_room_response]))
		return change_room_response
	else:
		return Types.wrap_system_text("This room has no exit in that direction!")
	
	return Types.wrap_system_text("Error parsing go")

func take(second_word: String) -> String:
	if second_word == " ":
		return Types.wrap_system_text("Takes what?")
	
	for item in current_room.items:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			return "Thijs takes the " + Types.wrap_item_text(second_word)
	
	return "No %s found in the %s!" % [Types.wrap_item_text(second_word), Types.wrap_location_text(current_room.room_name)]

func drop(second_word: String) -> String:
	if second_word == " ":
		return Types.wrap_system_text("Drops what?")
		
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.add_item(item)
			player.drop_item(item)
			return "Thijs drops the " + Types.wrap_item_text(item.item_name)
	
	return "No %s found in inventory!" % Types.wrap_item_text(second_word)

func use(second_word: String) -> String:
	if second_word == " ":
		return Types.wrap_system_text("Use what?")
		
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			match item.item_type:
				Types.ItemTypes.KEY:
					for exit in current_room.exits.values():
						if exit == item.use_value:
							exit.is_locked = false
							player.drop_item(item)
							return ("Thijs uses a %s to unlock a door to the %s" % [Types.wrap_item_text(item.item_name), Types.wrap_location_text(exit.get_other_room(current_room).room_name)] +
							"\n" + Types.wrap_npc_text("thijs") + ": \"" + Types.wrap_speech_text("Am I doing the right thing taking this initiative? No one told me I could take this key. I must be misunderstanding something.") + "\"")
					return "The %s does not unlock any doors in this room" % Types.wrap_item_text(item.item_name)
				_:
					return Types.wrap_system_text("Error - tried to use an item with an invalid type")
	
	return "Thijs has no %s!" % Types.wrap_item_text(second_word)

func talk(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Talk to whom?")
		
	for npc in current_room.npcs:
		if npc.NPC_name.to_lower() == second_word:
			var flavor_text_pre = ""
			var flavor_text_post = ""
			match second_word:
				"zuzu":
					flavor_text_pre = "Zuzu has just gotten back from her presentation in the aquarium. She seems relieved her assessment is over.\n"
					flavor_text_post = "\nThijs wants to ask her for reassurance, but doesn't."
				"rosa":
					flavor_text_pre = "Rosa is soldering some electronic parts with her headphones on. Thijs tries to wish her good luck with her presentation, but she doesn't seem to hear it.\n"
				"joseph":
					flavor_text_pre = "" if npc.has_received_quest_item else "Joseph sits behind his desk, tinkering with some crazy device, mumbling to himself. He's working with cables... [shake rate=20.0 level=5 connected=1]AAAH![/shake] He's completely entangled in cables. He couldn't get out even if he wanted to.\n"
					flavor_text_post = "" if npc.has_received_quest_item else "\nHe doesn't seem to notice."
				"manetta":
					flavor_text_pre = "Manetta looks disturbed\n"
				"marloes":
					return "Marloes gives an encouraging thumbs up!"
				"jeanne":
					return "Jeanne seems to be taking notes"
			
			var dialogue = npc.post_dialogue if npc.has_received_quest_item else npc.pre_dialogue
			return flavor_text_pre + Types.wrap_npc_text(npc.NPC_name) + ": \"" + Types.wrap_speech_text(dialogue) + "\"" + flavor_text_post
	
	return Types.wrap_system_text("That [person] does not exist in this room")

func read(second_word: String) -> String:
	if second_word == " ":
		return Types.wrap_system_text("Read what?")
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			match item.item_type:
				Types.ItemTypes.NOTE:
					if item.item_name == "cheatsheet": return "The cheatsheet reads: " + Types.wrap_speech_text("Don't forget you can use 'slides' at any time to get an overview of your slides!")
				_:
					return Types.wrap_system_text("This item has no text to read!")
	
	return "No %s found in inventory!" % Types.wrap_item_text(second_word)

func give(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Gives what?")
	
	var has_item := false
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			has_item = true
	if not has_item:
		return "Thijs has no %s" % Types.wrap_item_text(second_word)
		
	for npc in current_room.npcs:
		if npc.quest_item != null and second_word.to_lower() == npc.quest_item.item_name.to_lower():
			npc.has_received_quest_item = true
			drop(second_word)
			
			if npc.quest_reward != null:
				var reward = npc.quest_reward
				if "is_locked" in reward: # duck typing
					reward.is_locked = false
				else:
					printerr("Warning - tried to have a quest reward that is not implemented.")
				
			return "Thijs gives the %s to %s." % [Types.wrap_item_text(second_word), Types.wrap_npc_text(npc.NPC_name)]
	
	return "%s is not wanted here." % Types.wrap_item_text(second_word)

func show(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Show what?")
	
	match second_word:
		"what":
			emit_signal("slide_changed", "what")
			return "Thijs shows the slide titled what"
		"game":
			emit_signal("slide_changed", "game")
			return "Thijs shows the slide titled game"
		"why":
			emit_signal("slide_changed", "why")
			return "Thijs shows the slide titled why"
		"how":
			emit_signal("slide_changed", "how")
			return "Thijs shows the slide titled how"
		"forked-dialogues":
			emit_signal("slide_changed", "forked-dialogues")
			return "Thijs shows the slide titled forked-dialogues"
		"human-parser":
			emit_signal("slide_changed", "human-parser")
			return "Thijs shows the slide titled human-parser"
		_:
			return Types.wrap_system_text("No slide with that name")
	
	return Types.wrap_system_text("Error parsing show")

# second word currently not used; maybe used later to start presentation at specific slide
func start(second_word: String) -> String:
	if presenting:
		return Types.wrap_system_text("Thijs is already presenting!")
	
	presenting = true
	
	match second_word:
		"":
			emit_signal("start_presentation")
			return "Thijs starts presenting"
		"presentation":
			emit_signal("start_presentation")
			return "Thijs starts presenting"
		_:
			return Types.wrap_system_text("Start what?")
	
	return Types.wrap_system_text("Error parsing start") 

func pause() -> String:
	if presenting:
		presenting = false
		emit_signal("pause_presentation")
		return "Thijs takes a break from presenting"
	return Types.wrap_system_text("Thijs is not presenting at the moment")
	
func resume() -> String:
	if not presenting:
		presenting = true
		emit_signal("resume_presentation")
		return "Thijs resumes presenting"
	return Types.wrap_system_text("Thijs is already presenting")

func show_slides() -> String:
	return "\n".join(PackedStringArray([
		"Thijs can show these slides: ",
		"\twhat",
		"\tgame",
		"\twhy",
		"\thow",
		"\tforked-dialogues",
		"\thuman-parser"
	]))	

func inventory() -> String:
	return player.get_inventory_list()

func help() -> String:
	return "\n".join(PackedStringArray([
		"Thijs can understand these commands: ",
		"\tgo %s, " % Types.wrap_location_text("[location]"),
		"\ttake %s, " % Types.wrap_item_text("[item]"),
		"\tdrop %s, " % Types.wrap_item_text("[item]"),
		"\tuse %s, " % Types.wrap_item_text("[item]"),
		"\ttalk %s, " % Types.wrap_npc_text("[NPC]"),
		"\tgive %s, " % Types.wrap_item_text("[item]"),
		"\tinventory, ",
		"\thelp"
	]))

func change_room(new_room: GameRoom) -> String:
	current_room = new_room
	#emit_signal("room_changed", new_room)
	return new_room.get_full_description()





func hide():
	match current_room.room_name:
		"PZI office":
			return Types.wrap_system_text("Hiding in the office? That can only cause trouble. Come on, act professional!")
		"Aquarium":
			return ("Thijs tries to hide, but there's not much here to hide behind. Best they can do is open their laptop and hide behind it. But the moment they do, a noise escapes their mouth:" +
			"\n" + Types.wrap_npc_text("thijs") + ": \"" + Types.wrap_speech_text("Okay, I think I'm ready to present!") + "\"")
	return "Thijs hides for a few short seconds. But from what? From whom? The nerves come from within."
	
func scream() -> String:
	match current_room.room_name:
		"Aquarium":
			return "Thijs wants to scream. [shake freq=2.0 level=5 connected=1]Desperately[/shake]. But when they try, they hear themselves say:\n" + Types.wrap_npc_text("thijs") + ": \"" + Types.wrap_speech_text("Okay, I think I'm ready to present!") + "\""
		"XML":
			return ("Thijs can't remember the last time they screamed, really screamed, fully committed, from the bottom of their heart. But here, where no one will hear anything:" + 
			"\n\"" + Types.wrap_npc_text("thijs") + ": " + Types.wrap_speech_text("...") + "\"" +
			"\nNothing comes out. Why are you so afraid of others perceiving you, Thijs?")
	return "Thijs tries to scream, but nothing comes out. How will they present, if they can't even use their voice?"

func meditate() -> String:
	match current_room.room_name:
		"Aquarium":
			return ("Thijs tries to mediate. What's so hard about talking to nice people about something you care about? Lots of things, if you're honest with yourself. You want to express this. You SHOULD express this. You open your mouth to tell the world!" +
			"\n" + Types.wrap_npc_text("thijs") + ": \"" + Types.wrap_speech_text("Okay, I think I'm ready to present!") + "\"")
	return "Thijs tries to mediate, but this is no time for peace of mind. You can have all the peace of mind in the world, if you just get this over with! What's so hard about talking to nice people about something you care about?"

func relax():
	match current_room.room_name:
		"Aquarium":
			return ("Thijs tries to relax. But they don't want to. It's hard to say, but they actually feel a lot of excitement. Emotions are difficult to distinguish sometimes. But realizing this, they feel better." +
			"\n" + Types.wrap_npc_text("thijs") + ": \"" + Types.wrap_speech_text("Okay, I think I'm ready to present!") + "\"")
	return "Thijs knows they should relax. Breath. [wave amp=50.0 freq=5.0 connected=1]Take a chill pill[/wave]. The pressure of needing to relax is not relaxing."
