-- Prevent hard loading whilst an achievement is on screen.
function GameSetup:block_exec(...)
	if HudChallengeNotification and HudChallengeNotification.default_queue and #HudChallengeNotification.default_queue > 0 then 
		return true
	end

	return GameSetup.super.block_exec(self, ...)
end