/datum/interaction
	/// Название взаимодействия, используется в интерфейсе
	var/name
	/// Уникальный ключ для вызова взаимодействия
	var/key
	/// Font Awesome иконка для интерфейса
	var/fa_icon
	/// Звук который будет воспроизведён во время взаимодействия
	var/sound

	/// Нужны ли руки у участников?
	var/need_hands = FALSE
	/// Нужны ли ноги у участников?
	var/need_legs = FALSE
	/// Нужно ли открытое лицо у инициатора?
	var/need_mouth_open = FALSE
	/// Можно ли использовать взаимодействие будучи связанным?
	var/allow_restrained = FALSE

/datum/interaction/proc/can_interact(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user || !target)
		return

	if(need_hands)
		var/obj/item/organ/external/target_hand = target.bodyparts_by_name["r_hand" || "r_hand"]
		if(!target_hand)
			to_chat(user, "У [target.name] нет рук!")
			return FALSE

		var/obj/item/organ/external/user_hand = user.bodyparts_by_name["r_hand"]
		if(user.hand)
			user_hand = user.bodyparts_by_name["l_hand"]

		if(!user_hand)
			to_chat(user, "<span class='warning'>You try to use your hand, but it's missing!</span>")
			return FALSE

		if(user_hand && !user_hand.is_usable())
			to_chat(user, "<span class='warning'>You try to move your [user_hand.name], but cannot!</span>")
			return FALSE

/datum/interaction/proc/do_interaction(mob/user, mob/target)
	if(!can_interact(user, target))
		return

	user.custom_emote(EMOTE_VISIBLE, "[name] [target]")

/datum/interaction/handhsake
	name = "Пожать руку"
	key = "handshake"
	fa_icon = "handshake"
	need_hands = TRUE
