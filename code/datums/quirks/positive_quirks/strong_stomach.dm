/datum/quirk/strong_stomach
	name = "Strong Stomach"
	desc = "Вы можете есть еду с пола, не рискуя заболеть, а рвота сказывается на вас слабее."
	icon = FA_ICON_FACE_GRIN_BEAM_SWEAT
	value = 4
	mob_trait = TRAIT_STRONG_STOMACH
	gain_text = span_notice("Вы чувствуете, что можете съесть что угодно!")
	lose_text = span_danger("При виде еды на полу вас начинает слегка подташнивать.")
	medical_record_text = "Иммунная система пациента крепче среднего... По крайней мере, к пищевым отравлениям."
	mail_goodies = list(
		/obj/item/reagent_containers/applicator/pill/ondansetron,
	)
