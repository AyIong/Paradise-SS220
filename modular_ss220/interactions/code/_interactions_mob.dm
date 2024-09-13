#define COMSIG_DO_MOB_INTERACTION "do_mob_interaction"

/mob/MouseDrop(mob/M as mob, src_location, over_location, src_control, over_control, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_DO_MOB_INTERACTION, M, usr)

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species = /datum/species/human)
	. = ..()
	AddElement(/datum/element/interactions)
