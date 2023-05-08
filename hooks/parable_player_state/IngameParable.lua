require("lib/states/GameState")

IngameParableState = IngameParableState or class(IngamePlayerBaseState)

function IngameParableState:init(game_state_machine)
	IngameParableState.super.init(self, "ingame_parable", game_state_machine)
end

function IngameParableState:at_enter()
	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		end
	end

	local player = managers.player:player_unit()
	if player then
		player:base():set_enabled(true)
		player:character_damage():set_invulnerable(true)
	end
end

function IngameParableState:at_exit()
	local player = managers.player:player_unit()
	if player then
		player:base():set_enabled(false)
		player:character_damage():set_invulnerable(false)
	end
end

function IngameParableState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameParableState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameParableState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end