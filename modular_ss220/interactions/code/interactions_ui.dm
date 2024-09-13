/// A representation of the stripping UI
/datum/interactions_ui
	/// The owner who has the element /datum/element/interactions
	var/atom/movable/owner
	/// The interactions element itself
	var/datum/element/interactions/interactions

/datum/interactions_ui/New(atom/movable/owner, datum/element/interactions/interactions)
	. = ..()
	src.owner = owner
	src.interactions = interactions

/datum/interactions_ui/Destroy()
	owner = null
	interactions = null
	return ..()

/datum/interactions_ui/ui_host(mob/user)
	return owner

/datum/interactions_ui/ui_state(mob/user)
	return GLOB.strippable_state

/datum/interactions_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Interactions")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/interactions_ui/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list()

	var/list/interactions = list()
	for(var/interaction in subtypesof(/datum/interaction))
		var/datum/interaction/single_interaction = interaction
		interactions += list(list(
			"name" = single_interaction.name,
			"fa_icon" = single_interaction.fa_icon,
			"key" = single_interaction.key,
			"path" = interaction,
		))

	data["interactions"] = interactions
	data["name"] = "[owner]"
	return data

/datum/interactions_ui/ui_act(action, params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("interact")
			var/key = params["key"]
			var/datum/interaction/path
			for(var/interaction as anything in subtypesof(/datum/interaction))
				var/datum/interaction/type = interaction
				if(type.key != key)
					continue
				path = type

			new path()
			path.do_interaction(usr, owner)
			return TRUE
