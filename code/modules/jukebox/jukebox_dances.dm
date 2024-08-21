/mob/living/proc/lying_fix()
	animate(src, transform = null, time = 1, loop = 0)
	lying_prev = 0

/obj/machinery/jukebox/disco/proc/dance_setup()
	var/turf/center = get_turf(src)
	FOR_DVIEW(var/turf/turf, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(turf.x == center.x && turf.y > center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "red"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1 + get_dist(src, light)
			spotlights += light
			continue
		if(turf.x == center.x && turf.y < center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "purple"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1 + get_dist(src, light)
			spotlights += light
			continue
		if(turf.x > center.x && turf.y == center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "#ffff00"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1 + get_dist(src, light)
			spotlights += light
			continue
		if(turf.x < center.x && turf.y == center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "green"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1 + get_dist(src, light)
			spotlights += light
			continue
		if((turf.x + 1 == center.x && turf.y + 1 == center.y) || (turf.x + 2 == center.x && turf.y + 2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "sw"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1.4+get_dist(src, light)
			spotlights += light
			continue
		if((turf.x - 1 == center.x && turf.y - 1 == center.y) || (turf.x - 2 == center.x && turf.y - 2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "ne"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1.4 + get_dist(src, light)
			spotlights += light
			continue
		if((turf.x - 1 == center.x && turf.y + 1 == center.y) || (turf.x - 2 == center.x && turf.y + 2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "se"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1.4 + get_dist(src, light)
			spotlights += light
			continue
		if((turf.x + 1 == center.x && turf.y - 1 == center.y) || (turf.x + 2 == center.x && turf.y - 2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = "nw"
			light.light_power = 30 - (get_dist(src, light) * 8)
			light.range = 1.4 + get_dist(src, light)
			spotlights += light
			continue
		continue
	END_FOR_DVIEW

/obj/machinery/jukebox/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		new /obj/effect/temp_visual/hierophant/telegraph/edge(get_turf(src))
		sleep(0.5 SECONDS)

/obj/machinery/jukebox/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !music_player.active_song_sound)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				spawn(0)
					S.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				spawn(0)
					S.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				spawn(0)
					S.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(0.7 SECONDS)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(music_player.active_song_sound)
		for(var/obj/item/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(src) || !music_player.active_song_sound || QDELETED(glow))
				return
			if(glow.light_color == "red")
				glow.light_color = "nw"
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "green"
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.light_range = glow.range * 1.1
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "sw"
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "purple"
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * 1.15
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "se"
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#ffff00"
				glow.light_range = glow.range * 0.9
				glow.update_light()
				continue
			if(glow.light_color == "#ffff00")
				glow.light_color = "ne"
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "red"
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * 0.85
				glow.update_light()
				continue
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, PROC_REF(hierofunk))

		sleep(music_player.selection.song_beat)
		if(QDELETED(src))
			return

/obj/machinery/jukebox/disco/proc/dance(mob/living/dancer) // Show your moves
	set waitfor = FALSE
	if(dancer.client)
		if(!(dancer.client.prefs.sound & SOUND_DISCO)) // They dont want music or dancing
			rangers -= dancer // Doing that here as it'll be checked less often than in processing.
			return
		if(!(dancer.client.prefs.toggles2 & PREFTOGGLE_2_DANCE_DISCO)) // They just dont wanna dance
			return

	switch(rand(0,9))
		if(0 to 1)
			dance2(dancer)
		if(2 to 3)
			dance3(dancer)
		if(4 to 6)
			dance4(dancer)
		if(7 to 9)
			dance5(dancer)

/obj/machinery/jukebox/disco/proc/dance2(mob/living/dancer)
	for(var/i = 1, i < 10, i++)
		for(var/d in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
			dancer.setDir(d)
			if(i == WEST && !dancer.incapacitated())
				dancer.SpinAnimation(7, 1)
			sleep(0.1 SECONDS)
		sleep(2 SECONDS)

/obj/machinery/jukebox/disco/proc/dance3(mob/living/dancer)
	var/matrix/initial_matrix = matrix(dancer.transform)
	for(var/i in 1 to 75)
		if(!dancer)
			return
		switch(i)
			if(1 to 15)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(0, 1)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(16 to 30)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(1, -1)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(31 to 45)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(-1, -1)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(46 to 60)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(-1, 1)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(61 to 75)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(1, 0)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
		dancer.setDir(turn(dancer.dir, 90))
		switch(dancer.dir)
			if(NORTH)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(0,3)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(0,-3)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(3,0)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(-3,0)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
		sleep(0.1 SECONDS)
	dancer.lying_fix()

/obj/machinery/jukebox/disco/proc/dance4(mob/living/dancer)
	var/speed = rand(1, 3)
	set waitfor = 0
	var/time = 30
	while(time)
		sleep(speed)
		for(var/i in 1 to speed)
			dancer.setDir(pick(GLOB.cardinal))
			if(IS_HORIZONTAL(dancer))
				dancer.stand_up()
			else
				dancer.lay_down()
		time--

/obj/machinery/jukebox/disco/proc/dance5(mob/living/dancer)
	animate(dancer, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(dancer.transform)
	for(var/i in 1 to 60)
		if(!dancer)
			return
		if(i < 31)
			initial_matrix = matrix(dancer.transform)
			initial_matrix.Translate(0,1)
			animate(dancer, transform = initial_matrix, time = 1, loop = 0)
		if(i > 30)
			initial_matrix = matrix(dancer.transform)
			initial_matrix.Translate(0,-1)
			animate(dancer, transform = initial_matrix, time = 1, loop = 0)
		dancer.setDir(turn(dancer.dir, 90))
		switch(dancer.dir)
			if(NORTH)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(0,3)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(0,-3)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(3,0)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(dancer.transform)
				initial_matrix.Translate(-3,0)
				animate(dancer, transform = initial_matrix, time = 1, loop = 0)
		sleep(0.1 SECONDS)
	dancer.lying_fix()

/obj/machinery/jukebox/disco/proc/dance_over()
	QDEL_LIST_CONTENTS(spotlights)
	QDEL_LIST_CONTENTS(sparkles)
	for(var/mob/living/dancer in rangers)
		if(!dancer || !dancer.client)
			continue
		dancer.stop_sound_channel(CHANNEL_JUKEBOX)
	rangers = list()
