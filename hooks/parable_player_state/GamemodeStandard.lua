local new_state = "ingame_parable"
local new_state_class = IngameParableState

Gamemode.STATES[new_state] = new_state

Hooks:PostHook(GamemodeStandard, "setup_gsm", new_state .. "_SetupGSM", function(self, gsm, empty, setup_boot, setup_title)
	local new_state_object = new_state_class:new(gsm)
	local new_state_function = callback(nil, new_state_object, "default_transition")

	gsm._states[new_state_object:name()] = new_state_object
	local copy_transitions_state = "ingame_standard"

	for original_from_name, to_data in pairs(gsm._transitions) do
		for original_to_name, transition_function in pairs(to_data) do
			if original_from_name == copy_transitions_state then
				gsm._transitions[new_state_object:name()] = gsm._transitions[new_state_object:name()] or {}
				gsm._transitions[new_state_object:name()][original_to_name] = new_state_function
			elseif original_to_name == copy_transitions_state then
				gsm._transitions[original_from_name][new_state_object:name()] = transition_function
			end
		end
	end

	gsm._transitions[new_state_object:name()][copy_transitions_state] = new_state_function
	gsm._transitions[copy_transitions_state][new_state_object:name()] = transition_function
end)