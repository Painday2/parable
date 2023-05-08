BaseInteractionExt._pre_parable_is_in_required_state = BaseInteractionExt._pre_parable_is_in_required_state or BaseInteractionExt._is_in_required_state
function BaseInteractionExt:_is_in_required_state(movement_state)
	if movement_state == "parable" or movement_state == "parable_slide" or movement_state == "parable_fall" then
		return self._tweak_data.can_interact_in_civilian
	else
		return self:_pre_parable_is_in_required_state(movement_state)
	end
end