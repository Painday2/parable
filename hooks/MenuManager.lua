MenuManager._pre_parable_close_menu = MenuManager._pre_parable_close_menu or MenuManager.close_menu
function MenuManager:close_menu(menu_name)
	if menu_name == "kit_menu" or Global.parable_instant_restart then
		if Global.game_settings.single_player and menu_name == "menu_pause" then
			Application:set_pause(false)
			self:post_event("game_resume")
			SoundDevice:set_rtpc("ingame_sound", 1)
		end

		MenuManager.super.close_menu(self, menu_name)
	else
		self:_pre_parable_close_menu(menu_name)
	end
end