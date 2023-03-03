Hooks:PostHook(IngameWaitingForPlayersState, "at_enter", "ParableInstantReloadState", function(self)
	if Global.parable_instant_restart then
		managers.hud._hud_mission_briefing:hide()
		managers.menu_component:disable_mission_briefing_gui()
		MenuManager.super.close_menu(managers.menu, "kit_menu")
		game_state_machine:current_state():start_game_intro()

		self._instant_fade_out = managers.overlay_effect:play_effect({
			blend_mode = "normal",
			sustain = 3,
			fade_out = 0,
			play_paused = true,
			fade_in = 0,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		})

		Global.parable_instant_restart = false
	end

	self:_skip()
end)

function IngameWaitingForPlayersState:_chk_show_skip_prompt() end
function IngameWaitingForPlayersState:_create_blackscreen_loading_icon() end

Hooks:PreHook(IngameWaitingForPlayersState, "at_exit", "ParableInstantReloadFadeRemoval", function(self, next_state)
	if self._instant_fade_out then
		managers.overlay_effect:stop_effect(self._instant_fade_out)
		self._instant_fade_out = nil
	end
end)