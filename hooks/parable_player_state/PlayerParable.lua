PlayerParable = PlayerParable or class(PlayerCivilian)

function PlayerParable:enter(state_data, enter_data)
	PlayerParable.super.enter(self, state_data, enter_data)

	self._unit:inventory():hide_equipped_unit()
end

function PlayerParable:exit(state_data, new_state_name)
	PlayerParable.super.exit(self, state_data, new_state_name)

	state_data._last_state_velocity = self._last_velocity_xy
end