PlayerParableDead = PlayerParableDead or class(PlayerParable)

function PlayerParableDead:enter(state_data, enter_data)
	PlayerParableDead.super.enter(self, state_data, enter_data)

	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())

	local projectile_entry = managers.blackmarket:equipped_projectile()
	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade(managers.player:player_timer():time())
	else
		self:_interupt_action_throw_projectile(managers.player:player_timer():time())
	end

	self:_interupt_action_charging_weapon(managers.player:player_timer():time())

	self:_start_action_dead(managers.player:player_timer():time())
	self._unit:base():set_slot(self._unit, 4)
	self._unit:camera():camera_unit():base():set_target_tilt(80)
	self._unit:character_damage():on_incapacitated()
	self._unit:character_damage():on_incapacitated_state_enter()

	self._reequip_weapon = enter_data and enter_data.equip_weapon
	self._next_shock = 0.5
	self._taser_value = 0.5
end

function PlayerParableDead:exit(state_data, new_state_name)
	PlayerParableDead.super.exit(self, state_data)

	self:_end_action_dead(managers.player:player_timer():time())
	managers.environment_controller:set_taser_value(1)
end

function PlayerParableDead:interaction_blocked()
	return true
end

function PlayerParableDead:bleed_out_blocked()
	return true
end

function PlayerParableDead:_update_movement(t, dt)
	self:_update_network_position(t, dt, self._unit:position())
end

function PlayerParableDead:_update_check_actions(t, dt) end

function PlayerParableDead:_get_walk_headbob()
	return 0
end

function PlayerParableDead:tweak_data_clbk_reload() end

function PlayerParableDead:_start_action_dead(t)
	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("duck"))
	self._unit:camera()._camera_unit:base():animate_fov(75)

	if self._state_data._health_effect_value then
		managers.rumble:play("hard_land")
		self._ext_camera:play_shaker("player_fall_damage")

		self._unit:sound():play("player_hit")
		managers.environment_controller:hit_feedback_down()
		managers.hud:on_hit_direction(Vector3(0, 0, -1), HUDHitDirection.DAMAGE_TYPES.HEALTH, 0)

		self._state_data._health_effect_value = self._state_data._health_effect_value - 0.3
		managers.environment_controller:set_health_effect_value(self._state_data._health_effect_value)
	end
end

function PlayerParableDead:_end_action_dead(t)
	if not self:_can_stand() then return end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("stand"))
end