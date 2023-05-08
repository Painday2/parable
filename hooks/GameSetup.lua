Hooks:PostHook(GameSetup, "update", "ParableInstantReloadDelayTimer", function(self, t, dt)
	if self._exec_delay_t then
		self._exec_delay_t = self._exec_delay_t - dt

		if self._exec_delay_t < 0 then
			self._exec_delay_t = nil
		end
	end
end)

function GameSetup:exec(...)
	if Global.instant_level_load then
		self._exec_delay_t = 2.5
	end

	GameSetup.super.exec(self, ...)
end

function GameSetup:block_exec(...)
	if self._exec_delay_t then
		return true
	end

	return GameSetup.super.block_exec(self, ...)
end