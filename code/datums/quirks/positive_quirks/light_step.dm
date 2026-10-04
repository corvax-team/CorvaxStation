/datum/quirk/light_step
	name = "Light Step"
	desc = "Вы ходите мягким шагом; шаги и наступание на острые предметы будут тише и менее болезненными. Кроме того, вы не испачкаете руки и одежду, если наступите в кровь."
	icon = FA_ICON_SHOE_PRINTS
	value = 4
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("Ваша походка становится чуть грациознее.")
	lose_text = span_danger("Вы начинаете топать, как варвар.")
	medical_record_text = "Ловкость пациента выдаёт в нём недюжинные способности к скрытности."
	mail_goodies = list(/obj/item/clothing/shoes/sandal)
