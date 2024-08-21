/obj/machinery/jukebox
	name = "jukebox"
	desc = "A classic music player."
	icon = 'icons/obj/musician.dmi'
	icon_state = "jukebox"
	atom_say_verb =  "states"
	anchored = TRUE
	density = TRUE
	idle_power_consumption = 10
	active_power_consumption = 100
	max_integrity = 200
	integrity_failure = 100
	req_access = list(ACCESS_BAR)
	/// Cooldown between "Error" sound effects being played
	COOLDOWN_DECLARE(jukebox_error_cd)
	/// Cooldown between being allowed to play another song
	COOLDOWN_DECLARE(jukebox_song_cd)
	/// TimerID to when the current song ends
	var/song_timerid
	/// Does Jukebox require coin?
	var/need_coin = FALSE
	/// Inserted coin for payment
	var/obj/item/coin/payment
	/// The actual music player datum that handles the music
	var/datum/jukebox/music_player
	// Type of music_player
	var/jukebox_type = /datum/jukebox

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	music_player = new jukebox_type(src)

/obj/machinery/jukebox/Destroy()
	stop_music()
	QDEL_NULL(payment)
	QDEL_NULL(music_player)
	return ..()

/obj/machinery/jukebox/wrench_act(mob/user, obj/item/tool)
	if(music_player.active_song_sound || (resistance_flags & INDESTRUCTIBLE))
		return
	. = TRUE

	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return

	if(!anchored && !isinspace())
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE

	else if(anchored)
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE

	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

/obj/machinery/jukebox/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[initial(icon_state)]-broken"
	else
		icon_state = "[initial(icon_state)][music_player.active_song_sound ? "-active" : null]"

/obj/machinery/jukebox/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return

	if(music_player.active_song_sound)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask")

/obj/machinery/jukebox/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>This device must be anchored by a wrench!</span>")
		return

	if(!length(music_player.songs))
		to_chat(user, "<span class='warning'>Error: No music tracks have been authorized for your station. Petition Central Command to resolve this issue.</span>")
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return

	ui_interact(user)

/obj/machinery/jukebox/attack_ghost(mob/user)
	if(anchored)
		return ui_interact(user)

/obj/machinery/jukebox/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/coin))
		if(payment)
			to_chat(user, "<span class='info'>Coin is already inserted.</span>")
			return

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>Coin is stuck to you and cannot be inserted!</span>")
			return

		item.forceMove(src)
		payment = item
		playsound(src, 'sound/misc/coin_accept.ogg', 50, TRUE)
		to_chat(user, "<span class='notice'>You insert a coin into [src].</span>")
		add_fingerprint(user)
		ui_interact(user)

	if(item.GetID())
		if(allowed(user))
			need_coin = !need_coin
			to_chat(user, "<span class='notice'>You [need_coin ? "brought back" : "removed"] restrictions [need_coin ? "to" : "from"] [src].</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return

/obj/machinery/jukebox/obj_break()
	if(stat & BROKEN)
		return

	stat |= BROKEN
	idle_power_consumption = 0
	stop_music()

/obj/machinery/jukebox/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = ..()
	music_player.get_ui_data(data)

	data["admin"] = check_rights(R_ADMIN, FALSE, user)
	data["need_coin"] = need_coin
	data["payment"] = payment
	data["saveTrack"] = music_player.save_track
	data["startTime"] = music_player.start_time
	data["worldTime"] = world.time

	return data

/obj/machinery/jukebox/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	switch(action)
		if("toggle")
			if(isnull(music_player.active_song_sound))
				if(COOLDOWN_FINISHED(src, jukebox_song_cd))
					activate_music()
					return TRUE

				to_chat(user, "<span class='warning'>Error: The device is still resetting from the last activation, \
							it will be ready again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, jukebox_song_cd))].</span>")
				if(COOLDOWN_FINISHED(src, jukebox_error_cd))
					playsound(src, 'sound/misc/compiler-failure.ogg', 33, TRUE)
					COOLDOWN_START(src, jukebox_error_cd, 15 SECONDS)
				return FALSE
			else
				stop_music()
				return TRUE

		if("select_track")
			if(!isnull(music_player.active_song_sound))
				to_chat(user, "<span class='warning'>Error: You cannot change the song until the current one is over.</span>")
				return TRUE

			var/datum/track/new_song = music_player.songs[params["track"]]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return TRUE

			music_player.selection = new_song
			return TRUE

		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume == "reset")
				music_player.reset_volume()
			else if(new_volume == "min")
				music_player.set_new_volume(0)
			else if(new_volume == "max")
				music_player.set_volume_to_max()
			else if(isnum(text2num(new_volume)))
				music_player.set_new_volume(text2num(new_volume))
			return TRUE

		if("loop")
			music_player.sound_loops = !!params["looping"]
			return TRUE

		if("add_song")
			if(!check_rights(R_ADMIN, FALSE))
				message_admins("[key_name(user)] tried to add a track without having admin rights!")
				log_admin("[key_name(user)] tried to add a track without having admin rights!")
				return FALSE

			var/track_name = params["track_name"]
			var/track_length = params["track_length"]
			var/track_beat = params["track_beat"]
			if(!track_name || !track_length || !track_beat)
				to_chat(user, "<span class='warning'>Ошибка: Имеются не заполненные поля.</span>")
				return FALSE

			var/track_file = upload_file(user)
			upload_track(user, track_name, track_length, track_beat, track_file)
			try_save_file(user, track_name, track_length, track_beat, track_file)
			return TRUE

		if("save_song")
			if(!check_rights(R_ADMIN, FALSE))
				message_admins("[key_name(user)] tried to enable track saving without having admin rights!")
				log_admin("[key_name(user)] tried to enable track saving without having admin rights!")
				return FALSE

			enable_saving(user)
			return TRUE

/obj/machinery/jukebox/proc/activate_music()
	if(!isnull(music_player.active_song_sound))
		return FALSE

	music_player.start_music()
	change_power_mode(ACTIVE_POWER_USE)
	update_icon()
	if(!music_player.sound_loops)
		song_timerid = addtimer(CALLBACK(src, PROC_REF(stop_music)), music_player.selection.song_length, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

	return TRUE

/obj/machinery/jukebox/proc/stop_music()
	if(!isnull(song_timerid))
		deltimer(song_timerid)

	music_player.unlisten_all()
	QDEL_NULL(payment)

	if(!QDELING(src))
		COOLDOWN_START(src, jukebox_song_cd, 5 SECONDS)
		playsound(src,'sound/machines/terminal_off.ogg', 50, TRUE)
		change_power_mode(IDLE_POWER_USE)
		update_icon()

	return TRUE

/obj/machinery/jukebox/proc/upload_file(mob/user)
	var/file = input(user, "Upload a file with size no more than 5mb, only .ogg format is supported", "Uploading a file") as null|file
	if(isnull(file))
		to_chat(user, "<span class='warning'>Error: File selection is required.</span>")
		return
	if(copytext("[file]", -4) != ".ogg")
		to_chat(user, "<span class='warning'>File format should be '.ogg': [file]</span>")
		return
	return file

/obj/machinery/jukebox/proc/upload_track(mob/user, name, length, beat, file)
	var/datum/track/new_track = new()
	new_track.song_name = name
	new_track.song_length = length
	new_track.song_beat = beat
	new_track.song_path = file(file)

	music_player.songs[name] = new_track
	atom_say("New track uploaded: «[name]»")

/obj/machinery/jukebox/proc/enable_saving(mob/user)
	if(music_player.save_track)
		music_player.save_track = !music_player.save_track
		return

	if(tgui_alert(user, "Are you sure you want to save track on the server?", "Track saving", list("Yes", "No")) != "Yes")
		return

	if(tgui_alert(user, "Attention! ONLY the host will be able to delete the saved track! Please fill in the fields as responsibly as possible!", "Track saving", list("Got it", "I've changed my mind")) != "Got it")
		return

	music_player.save_track = !music_player.save_track

/obj/machinery/jukebox/proc/try_save_file(mob/user, name, length, beat, file)
	if(!music_player.save_track)
		return

	if(tgui_alert(user, "WARNING: Track saving to the server is enabled. <br> \
			By clicking “Yes” you confirm that the downloaded track does not violate any copyright. <br> \
			Are you sure you want to save the track?", "Track saving", list("Yes", "No")) != "Yes")
		music_player.save_track = !music_player.save_track
		to_chat(user, "<span class='warning'>Track saving has been disabled.</span>")
		return

	var/config_file = "[name]" + "+" + "[length]" + "+" + "[beat]"
	if(!fcopy(file, "config/jukebox_music/sounds/[config_file].ogg"))
		to_chat(user, "<span class='warning'>For some reason, track was not saved, please try again. <br> Input file: [file] <br> Output file: [config_file].ogg</span>")
		return

	to_chat(user, "<span class='notice'>Your track has been successfully uploaded to the server under the following name: [config_file].ogg</span>")
	message_admins("[key_name(user)] uploaded the track [config_file].ogg with the original name [file] on server")
	log_admin("[key_name(user)] uploaded the track [config_file].ogg with the original name [file] on server")

/obj/machinery/jukebox/bar
	need_coin = TRUE

/obj/machinery/jukebox/disco
	name = "radiant dance machine mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon_state = "disco"
	base_icon_state = "disco"
	anchored = FALSE
	max_integrity = 300
	integrity_failure = 150
	var/list/rangers = list()

	/// Spotlight effects being played
	VAR_PRIVATE/list/obj/item/flashlight/spotlight/spotlights = list()
	/// Sparkle effects being played
	VAR_PRIVATE/list/obj/effect/overlay/sparkles/sparkles = list()

/obj/machinery/jukebox/disco/immobile
	name = "radiant dance machine mark V"
	desc = "The mark V is nigh-immovable, thanks to its bluespace-plastitanium anchor. The technology required to stop visitors from stealing this thing is astounding."
	anchored = TRUE

/obj/machinery/jukebox/disco/immobile/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/jukebox/disco/immobile/wrench_act()
	return FALSE

/obj/machinery/jukebox/disco/chaos_staff
	anchored = TRUE

/obj/machinery/jukebox/disco/chaos_staff/Initialize(mapload)
	. = ..()
	music_player.sound_loops = TRUE
	INVOKE_ASYNC(src, PROC_REF(activate_music))

/obj/machinery/jukebox/disco/chaos_staff/ui_act(action, list/params)
	if(check_rights(R_ADMIN, FALSE, usr))
		..()
	else
		to_chat(usr, "<span class='biggerdanger'>YOU HAVE NO POWER HERE! DANCE!!!</span>")
		return

/obj/machinery/jukebox/disco/activate_music()
	. = ..()
	if(!.)
		return

	dance_setup()
	lights_spin()
	START_PROCESSING(SSobj, src)

/obj/machinery/jukebox/disco/stop_music()
	. = ..()
	if(!.)
		return

	QDEL_LIST_CONTENTS(spotlights)
	QDEL_LIST_CONTENTS(sparkles)
	STOP_PROCESSING(SSobj, src)

/obj/machinery/jukebox/disco/process()
	for(var/mob/living/dancer in music_player.get_active_listeners())
		if(!(dancer.mobility_flags & MOBILITY_MOVE))
			continue
		dance(dancer)
