/client/verb/jukebox_manager()
	set name = "Jukebox Manager"
	set category = "Admin"
	set desc = "View uploaded songs to the jukebox and manage it."

	var/datum/ui_module/jukebox_manager/manager = new()
	manager.ui_interact(usr)

/datum/ui_module/jukebox_manager
	name = "Jukebox Manager"
	/// Jukebox datum, used for songs list.
	var/datum/jukebox/parent

/datum/ui_module/jukebox_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/jukebox_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JukeboxManager", name)
		ui.autoupdate = FALSE
		ui.open()

/datum/ui_module/jukebox_manager/ui_data(mob_user)
	var/list/data = list()
	data["songs"] = scan_songs_list()
	return data

/datum/ui_module/jukebox_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!check_rights(R_ADMIN, FALSE))
		return

	var/mob/user = usr
	switch(action)
		if("delete")
			var/track_path = params["path"]
			if(findtext(track_path, parent.songs_path) && fexists(track_path))
				fdel(track_path)
				to_chat(user, "<span class='notice'>[params["name"]] successfully deleted.</span>")
			else
				to_chat(user, "<span class='notice'>Track removed from jukeboxes.</span>")

			parent.songs.Remove(params["name"])
			return TRUE

		if("download")
			if(tgui_alert(user, "Are you sure you want to download this track?", "Track download", list("Yes", "No")) != "Yes")
				return FALSE

			user << ftp(params["path"], "[params["name"]].ogg")

		if("refresh")
			scan_songs_list()

/**
 * Scanning songs list in /datum/jukebox
 * Returns list of songs for UI
 */
/datum/ui_module/jukebox_manager/proc/scan_songs_list()
	var/list/songs_data = list()
	if(length(parent.songs) != 0)
		for(var/song_name in parent.songs)
			var/datum/track/one_song = parent.songs[song_name]
			UNTYPED_LIST_ADD(songs_data, list( \
				"name" = song_name, \
				"length" = one_song.song_length, \
				"beat" = one_song.song_beat, \
				"path" = one_song.song_path, \
				"hosted" = one_song.hosted, \
			))
	return songs_data
