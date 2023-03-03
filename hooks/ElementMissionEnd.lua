Hooks:PreHook(ElementMissionEnd, "on_executed", "ParableInstantReloadFailure", function(self, instigator)
	if not self._values.enabled then return end
	if self._values.state == "none" or managers.platform:presence() ~= "Playing" then return end

	if self._values.state == "failed" then
		Global.parable_instant_restart = true

		managers.criminals:save_current_character_names()
		managers.job:stop_sounds()
		MenuCallbackHandler:start_the_game()

		self._values.enabled = false
	end
end)