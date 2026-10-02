/datum/controller/subsystem/blackbox/LogAhelp(ticket, action, message, recipient, sender, urgent = FALSE)
	// admin_ticket_log relays these itself, even when it skips the blackbox
	if(action != TICKET_AHELP_ACTION_ASSIGNED)
		SScentral.relay_ticket_event(GLOB.ticket_manager.get_help_ticket_by_id(ticket), action, sender, message)
	return ..()

/datum/controller/subsystem/central/proc/relay_ticket_event(datum/help_ticket/ticket, action, sender, message)
	if(!ticket || !can_run())
		return

	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/tickets/events"
	var/list/headers = list()
	headers["Authorization"] = "Bearer [CONFIG_GET(string/ss_central_token)]"

	var/is_pm = ticket.ticket_type_hidden == TICKET_TYPE_HIDDEN_PM
	var/list/admin_counts = get_admin_counts(ticket.get_ticket_type()?.required_permissions || R_ADMIN)

	var/list/body = list()
	body["server"] = CONFIG_GET(string/servername)
	body["round_id"] = GLOB.round_id
	body["round_time"] = SSticker.current_state == GAME_STATE_PLAYING ? round_timestamp() : null
	body["ticket_id"] = ticket.id
	body["ticket_type"] = is_pm ? TICKET_TYPE_HIDDEN_PM : ticket.ticket_type_id
	body["player_ckey"] = ckey(ticket.initiator_key)
	body["character"] = ticket.initiator_client?.mob?.real_name
	body["action"] = action
	body["sender"] = sender
	body["message"] = strip_html_full(message)
	body["admins_online"] = length(admin_counts["present"]) + length(admin_counts["stealth"])
	body["urgent"] = ticket.is_urgent

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, json_encode(body), headers)
