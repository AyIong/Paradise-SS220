/datum/element/interactions
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// Существующие интерфейсы взаимодействий
	var/list/interactions_uis

/datum/element/interactions/Attach(datum/target, list/items = list())
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_DO_MOB_INTERACTION, PROC_REF(mouse_drop_into))

/datum/element/interactions/Detach(datum/source)
	. = ..()

	UnregisterSignal(source, COMSIG_DO_MOB_INTERACTION)

	if(!isnull(interactions_uis))
		qdel(interactions_uis[source])
		interactions_uis -= source

/datum/element/interactions/proc/mouse_drop_into(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(user != source)
		return

	if(over == user)
		return

	var/datum/interactions_ui/interactions = LAZYACCESS(interactions_uis, source)
	if(isnull(interactions_uis))
		interactions = new(over, src)
		LAZYSET(interactions_uis, source, interactions)

	INVOKE_ASYNC(interactions, TYPE_PROC_REF(/datum, ui_interact), user)
