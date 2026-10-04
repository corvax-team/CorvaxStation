#define DERELICT_VAULT_ID "derelictvault"

/////////// thederelict items

/obj/item/paper/fluff/ruins/thederelict/equipment
	default_raw_text = "If the equipment breaks there should be enough spare parts in our engineering storage near the north east solar array."
	name = "Equipment Inventory"

/obj/item/paper/fluff/ruins/thederelict/syndie_mission
	name = "Mission Objectives"
	default_raw_text = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/fluff/ruins/thederelict/nukie_objectives
	name = "Objectives of a Nuclear Operative"
	default_raw_text = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/crumpled/bloody/ruins/thederelict/unfinished
	name = "unfinished paper scrap"
	desc = "Looks like someone started shakily writing a will in space common, but were interrupted by something bloody..."
	default_raw_text = "I, Victor Belyakov, do hereby leave my _- "

/obj/item/paper/fluff/ruins/thederelict/vaultraider
	name = "Vault Raider Objectives"
	default_raw_text = "<b>Objectives #1</b>: Find out what is hidden in Kosmicheskaya Stantsiya 13s Vault"

///The Derelict Terminals
/obj/machinery/computer/terminal/derelict/bridge
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	content = list("Central Command Status Summary -- Impending Doom -- Your station is somehow in the middle of hostile territory, in clear view of any enemy of the corporation. Your likelihood to survive is low, \
	and station destruction is expected and almost inevitable. Secure any sensitive material and neutralize any enemy you will come across. It is important that you at least try to maintain the station. \
	Good luck. -- Special Orders for KC13: Our military presence is inadequate in your sector. We need you to construct BSA-87 Artillery position aboard your station. Base parts are available for shipping via cargo. \
	-Nanotrasen Naval Command -- Identified Shift Divergences: Overflow bureaucracy mistake - It seems for some reason we put out the wrong job-listing for the overflow role this shift...I hope you like captains.")

/obj/machinery/computer/terminal/derelict/cargo
	content = list("INTER-MAIL - #789 - Cargo Technician I. Miller -> J. Holmes -- Jake, with all due respect, I don't know how you guys can keep this shit up. Robotics has made not one, but THREE AIs, \
	and at least one of them either has combat upgrades or isn't telling us the whole story. Not that we can even get close enough to tell, mind, they're doing everything in their power to keep us away. It's \
	unnerving. Meanwhile, a little birdie tells me one of your officers has been spending all shift trying to get their baton back from the clown with.. lethal force. This place is a fucking powder keg, Jake, \
	you know as well as I do. Either stop fucking around or we'll take matters into our own hands.")

/obj/machinery/computer/terminal/derelict/security
	content = list("INTER-MAIL - #790 - Cargo Technician J. Holmes -> I. Miller -- HOT SINGLE SILICONS IN YOUR AREA, CLICK ->HERE<- FOR MORE INFORMATION!")

/// Vault controller for use on the derelict/KS13.
/obj/machinery/computer/vaultcontroller
	name = "vault controller"
	desc = "It seems to be powering and controlling the vault locks."
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/vaultcontroller")
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_DIM_YELLOW
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/door_id = DERELICT_VAULT_ID
	var/obj/structure/cable/attached_cable
	var/obj/machinery/door/airlock/vault/derelict/door1
	var/obj/machinery/door/airlock/vault/derelict/door2
	var/locked = TRUE
	var/siphoned_power = 0
	var/siphon_max = 1e7

/obj/machinery/computer/monitor/examine(mob/user)
	. = ..()
	. += span_notice("It appears to be powered via a cable connector.")

//Checks for cable connection, charges if possible.
/obj/machinery/computer/vaultcontroller/process()
	if(siphoned_power >= siphon_max)
		return
	update_cable()
	if(attached_cable)
		attempt_siphon()

///Looks for a cable connection beneath the machine.
/obj/machinery/computer/vaultcontroller/proc/update_cable()
	var/turf/T = get_turf(src)
	attached_cable = locate(/obj/structure/cable) in T

///Initializes airlock links.
/obj/machinery/computer/vaultcontroller/proc/find_airlocks()
	for(var/obj/machinery/door/airlock/A as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(A.id_tag == door_id)
			if(!door1)
				door1 = A
				continue
			if(door1 && !door2)
				door2 = A
				break

///Tries to charge from powernet excess, no upper limit except max charge.
/obj/machinery/computer/vaultcontroller/proc/attempt_siphon()
	var/surpluspower = clamp(attached_cable.surplus(), 0, (siphon_max - siphoned_power))
	if(surpluspower)
		attached_cable.add_load(surpluspower)
		siphoned_power += surpluspower

///Handles the doors closing
/obj/machinery/computer/vaultcontroller/proc/cycle_close(obj/machinery/door/airlock/A)
	A.safe = FALSE //Make sure its forced closed, always
	A.unbolt()
	A.close()
	A.bolt()

///Handles the doors opening
/obj/machinery/computer/vaultcontroller/proc/cycle_open(obj/machinery/door/airlock/A)
	A.unbolt()
	A.open()
	A.bolt()

///Attempts to lock the vault doors
/obj/machinery/computer/vaultcontroller/proc/lock_vault()
	if(door1 && !door1.density)
		cycle_close(door1)
	if(door2 && !door2.density)
		cycle_close(door2)
	if(door1.density && door1.locked && door2.density && door2.locked)
		locked = TRUE

///Attempts to unlock the vault doors
/obj/machinery/computer/vaultcontroller/proc/unlock_vault()
	if(door1?.density)
		cycle_open(door1)
	if(door2?.density)
		cycle_open(door2)
	if(!door1.density && door1.locked && !door2.density && door2.locked)
		locked = FALSE

///Attempts to lock/unlock vault doors, if machine is charged.
/obj/machinery/computer/vaultcontroller/proc/activate_lock()
	if(siphoned_power < siphon_max)
		return
	if(!door1 || !door2)
		find_airlocks()
	if(locked)
		unlock_vault()
	else
		lock_vault()

/obj/machinery/computer/vaultcontroller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VaultController", name)
		ui.open()

/obj/machinery/computer/vaultcontroller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("togglelock")
			activate_lock()

/obj/machinery/computer/vaultcontroller/ui_data()
	var/list/data = list()
	data["stored"] = siphoned_power
	data["max"] = siphon_max
	data["doorstatus"] = locked
	return data

///Airlock that can't be deconstructed, broken or hacked.
/obj/machinery/door/airlock/vault/derelict
	locked = TRUE
	move_resist = INFINITY
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	id_tag = DERELICT_VAULT_ID
	has_access_panel = FALSE

///Overrides screwdriver act to prevent all deconstruction and hacking. Override for extra tuff fluff
/obj/machinery/door/airlock/vault/derelict/screwdriver_act(mob/living/user, obj/item/tool)
	to_chat(user, span_danger("The robust make of [src] makes it impossible to access the panel in any way!"))
	return ITEM_INTERACT_SUCCESS

/obj/structure/fluff/oldturret
	name = "broken turret"
	desc = "An obsolete model of turret, long non-functional."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "turretCover"
	density = TRUE

/// Captain's log
/// Credits to goonstation13 for orginal SS13 lore
/// https://wiki.ss13.co/Storyline
/// https://www.youtube.com/watch?v=7M-JPH5SOmI (old video)
/// https://www.youtube.com/watch?v=FHH1vfY6HTA (new video)
/obj/item/tape/captains_log
	name = "captain's log"
	desc = "A dusty old tape."
	icon_state = "tape_blue"
	used_capacity = 10 MINUTES // so the tape is full and can't be recorded over
	storedinfo = list( // the captain recorded this in several segements
		// 1st monologue (start of shift)
		new /datum/tape_message("00:01", text = "Каждый день, проведенный на этой станции"),
		new /datum/tape_message("00:07", text = "Я всё больше убеждаюсь, что это назначение было каким-то изощрённым наказанием"),
		new /datum/tape_message("00:17", text = "Не знаю, чем я заслужил ссылку на этот кое-как склеенный ком орбитального хлама"),
		new /datum/tape_message("00:28", text = "Но кто-то явно точит на меня зуб"),
		new /datum/tape_message("00:36", text = "На станции меня, может, и называют 'Капитаном'"),
		new /datum/tape_message("00:42", text = "Но престижа и ответственности в этом звании не больше, чем у грёбаного воспитателя в детском саду для переростков"),
		new /datum/tape_message("00:55", text = "И подумать только, Нанотрейзен любит называть эту адскую дыру:"),
		new /datum/tape_message("01:03", text = "Современнейшей орбитальной станцией по исследованию плазмы"),
		new /datum/tape_message("01:10", text = "Хотя, если я правильно помню"),
		new /datum/tape_message("01:15", text = "Всё это было ради плазмы"),
		new /datum/tape_message("01:19", text = "Она была как новая нефть"),
		new /datum/tape_message("01:25", text = "Как только мы разделались со всей этой весёлой хренью про исследования и открытия"),
		new /datum/tape_message("01:35", text = "Мы начали бурить"),
		new /datum/tape_message("01:40", text = "Все компании и целые отрасли хотели хлебать её вёдрами"),
		new /datum/tape_message("01:48", text = "Хотя мы ни хрена о ней не знали и не знаем до сих пор"),
		new /datum/tape_message("01:55", text = "Но это их не остановило"),
		new /datum/tape_message("01:59", text = "(щелчок)"),
		// 2nd monologue (early shift)
		new /datum/tape_message("15:05", text = "И вот мне дают экипаж из учёных и инженеров, чтобы изучить и освоить эту так называемую плазму"),
		new /datum/tape_message("15:15", text = "Не говоря уже о НЕКОМПЕТЕНТНОЙ охране"),
		new /datum/tape_message("15:20", text = "Поваре-МАНЬЯКЕ"),
		new /datum/tape_message("15:25", text = "ПОДОЗРИТЕЛЬНОМ, мать его, детективе"),
		new /datum/tape_message("15:29", text = "БЕСПОЛЕЗНОМ клоуне"),
		new /datum/tape_message("15:35", text = "И ПОЛОУМНЫХ, чёрт бы их побрал, уборщиках"),
		new /datum/tape_message("15:46", text = "Сюда же относится сварливый кусок дерьма от IBM, который нам положено называть ИИ"),
		new /datum/tape_message("15:52", text = "И его легион киборгов-ублюдков"),
		new /datum/tape_message("15:58", text = "Как будто этого мало, приходится ещё беспокоиться из-за Федерации магов"),
		new /datum/tape_message("16:06", text = "Сумасшедшие ублюдки"),
		new /datum/tape_message("16:10", text = "Что может быть хуже кучки помешанных на плазме космических уродов?"),
		new /datum/tape_message("16:17", text = "Синдикат"),
		new /datum/tape_message("16:21", text = "Одержимый желанием разнести всё, чего мы достигли, к чертям собачьим"),
		new /datum/tape_message("16:27", text = "И всё же экипаж продолжает заниматься своими повседневными делами"),
		new /datum/tape_message("16:33", text = "Постоянно оглядываясь и подозревая друг друга"),
		new /datum/tape_message("16:40", text = "А кто бы не стал? Даже за обезьянами для генетических опытов тут следят круглосуточно"),
		new /datum/tape_message("16:52", text = "Несмотря на всё это"),
		new /datum/tape_message("16:56", text = "Эти жестокие, параноидальные отбросы каждую свободную от сна минуту оттачивают свои боевые навыки"),
		new /datum/tape_message("17:00", text = "Или с благоговением гадают, что сулит им плазма"),
		new /datum/tape_message("17:07", text = "И если что-то пойдет не так, это не проблема"),
		new /datum/tape_message("17:17", text = "Наши передовые генетики и медики обеспечат вторую жизнь за считанные минуты"),
		// 3rd monologue (middle shift)
		new /datum/tape_message("28:03", text = "Я не знаю, зачем я вообще это записываю..."),
		new /datum/tape_message("28:13", text = "Мне самому это уж точно ни к чёрту не нужно"),
		new /datum/tape_message("28:25", text = "Конечно, я мог бы выложить это вместе со всеми уликами и компроматом на Нанотрейзен, что я накопал за эти годы"),
		new /datum/tape_message("28:32", text = "Но в чем смысл?"),
		new /datum/tape_message("28:36", text = "Кому до этого будет дело, кроме корпорации, которая устроит мне внезапное исчезновение?"),
		new /datum/tape_message("28:47", text = "Пожалуй, я мог бы выложить это в сеть, и пусть люди судят сами"),
		new /datum/tape_message("28:59", text = "В конце концов, это ведь я сижу тут, в глубоком космосе, и неспешно дрейфую"),
		// 4th monologue (end of shift)
		new /datum/tape_message("47:01", text = "Мне плевать, как меня называют там, на станции"),
		new /datum/tape_message("47:06", text = "Я не предатель!"),
		new /datum/tape_message("47:10", text = "Я человек с принципами и стандартами"),
		new /datum/tape_message("47:17", text = "И если на пути этих принципов встают чьи-то жизни, так тому и быть"),
		new /datum/tape_message("47:22", text = "Я бы сказал, что я тут достойнее их всех"),
		new /datum/tape_message("47:32", text = "Когда-то меня называли капитаном, но когда всё закончится"),
		new /datum/tape_message("47:41", text = "Я буду героем"),
		new /datum/tape_message("47:45", text = "Если ты случайно наткнёшься на эту передачу"),
		new /datum/tape_message("47:52", text = "Тащи свою пухлую задротскую задницу на Космическую Станцию 13 и начинай проламывать головы."),
		new /datum/tape_message("48:00", text = "(звуки пердежа)"),
	)
	timestamp = list(
		// 1st monologue (start of shift)
		1 SECONDS,
		7 SECONDS,
		17 SECONDS,
		28 SECONDS,
		36 SECONDS,
		42 SECONDS,
		55 SECONDS,
		1 MINUTES + 3 SECONDS,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 15 SECONDS,
		1 MINUTES + 19 SECONDS,
		1 MINUTES + 25 SECONDS,
		1 MINUTES + 35 SECONDS,
		1 MINUTES + 40 SECONDS,
		1 MINUTES + 48 SECONDS,
		1 MINUTES + 55 SECONDS,
		1 MINUTES + 59 SECONDS,
		// 2nd monologue (early shift)
		15 MINUTES + 5 SECONDS,
		15 MINUTES + 15 SECONDS,
		15 MINUTES + 20 SECONDS,
		15 MINUTES + 25 SECONDS,
		15 MINUTES + 29 SECONDS,
		15 MINUTES + 35 SECONDS,
		15 MINUTES + 46 SECONDS,
		15 MINUTES + 52 SECONDS,
		15 MINUTES + 58 SECONDS,
		16 MINUTES + 6 SECONDS,
		16 MINUTES + 10 SECONDS,
		16 MINUTES + 17 SECONDS,
		16 MINUTES + 21 SECONDS,
		16 MINUTES + 27 SECONDS,
		16 MINUTES + 33 SECONDS,
		16 MINUTES + 40 SECONDS,
		16 MINUTES + 52 SECONDS,
		16 MINUTES + 56 SECONDS,
		17 MINUTES + 0 SECONDS,
		17 MINUTES + 7 SECONDS,
		17 MINUTES + 17 SECONDS,
		// 3rd monologue (middle shift)
		28 MINUTES + 3 SECONDS,
		28 MINUTES + 13 SECONDS,
		28 MINUTES + 25 SECONDS,
		28 MINUTES + 32 SECONDS,
		28 MINUTES + 36 SECONDS,
		28 MINUTES + 47 SECONDS,
		28 MINUTES + 59 SECONDS,
		// 4th monologue (end of shift)
		47 MINUTES + 1 SECONDS,
		47 MINUTES + 6 SECONDS,
		47 MINUTES + 10 SECONDS,
		47 MINUTES + 17 SECONDS,
		47 MINUTES + 22 SECONDS,
		47 MINUTES + 32 SECONDS,
		47 MINUTES + 41 SECONDS,
		47 MINUTES + 45 SECONDS,
		47 MINUTES + 52 SECONDS,
		48 MINUTES + 0 SECONDS,
	)

/obj/item/tape/captains_log/Initialize(mapload)
	. = ..()
	unspool() // the tape spawns damaged

#undef DERELICT_VAULT_ID
