/datum/quirk/pushover
	name = "Pushover"
	desc = "Ваш первый порыв - всегда позволять другим помыкать собой. Чтобы вырваться из захвата, вам потребуется сознательное усилие."
	icon = FA_ICON_HANDSHAKE
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("Вы чувствуете себя тряпкой.")
	lose_text = span_notice("Вам хочется постоять за себя.")
	medical_record_text = "Пациент демонстрирует необычайно неуверенный характер, и им легко манипулировать."
	hardcore_value = 4
	mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)
