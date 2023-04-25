Hooks:PostHook(HUDManager, "load_hud", "pain_parable_disable_hud", function(self, tweak_data)
	self:set_disabled()
end)

function HUDManager:_toggle_hud_callback()
end