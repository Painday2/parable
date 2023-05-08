Hooks:PostHook(PlayerManager, "init", "PlayerParable_setup_player_states", function(self)
	self._player_states["parable"] = "ingame_parable"
	self._player_states["parable_fall"] = "ingame_parable"
	self._player_states["parable_slide"] = "ingame_parable"
end)