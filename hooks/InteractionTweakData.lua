Hooks:PostHook(InteractionTweakData, "init", "pain_parable_interactions", function(self, tweak_data)

	self.invisible_parable = {
		text_id = "int_invisible",
		start_active = false,
		interact_distance = 100,
		can_interact_in_civilian = true
	}
end)