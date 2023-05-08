PlayerParableFall = PlayerParableFall or class(PlayerParable)

function PlayerParableFall:init(unit)
	PlayerParableFall.super.init(self, unit)

	self._tweak_data = tweak_data.player.freefall
	self._dt = 0
end

function PlayerParableFall:enter(state_data, enter_data)
	PlayerParableFall.super.enter(self, state_data, enter_data)

	if self._state_data.ducking then
		self:_end_action_ducking()
	end

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

	self._original_damping = self._unit:mover():damping()

	self._unit:mover():set_damping(self._tweak_data.gravity / self._tweak_data.terminal_velocity)
	self._unit:sound():play("free_falling", nil, false)
end

function PlayerParableFall:_enter(enter_data)
	self._unit:movement().fall_rotation = self._unit:movement().fall_rotation or Rotation(0, 0, 0)

	self:_pitch_down()
	self:_set_camera_limits()

	self._shaker_id = self._ext_camera:shaker():play("player_freefall", 0)
end

function PlayerParableFall:exit(state_data, new_state_name)
	PlayerParableFall.super.exit(self, state_data)

	self._unit:mover():set_damping(self._original_damping or 1)
	self:_remove_camera_limits()
	self._ext_camera:shaker():stop(self._shaker_id)

	self._unit:sound():stop()
end

function PlayerParableFall:interaction_blocked()
	return true
end

function PlayerParableFall:bleed_out_blocked()
	return true
end

function PlayerParableFall:update(t, dt)
	PlayerParableFall.super.update(self, t, dt)

	self._last_shake_update = (self._last_shake_update or 0) + dt

	if self._last_shake_update > 0.2 then
		local shake_amplitude = math.lerp(self._tweak_data.camera.shake.min, self._tweak_data.camera.shake.max, math.abs(self._unit:mover():velocity().z) / self._tweak_data.terminal_velocity)

		self._ext_camera:shaker():set_parameter(self._shaker_id, "amplitude", shake_amplitude)

		self._last_shake_update = 0
	end
end

function PlayerParableFall:_update_movement(t, dt)
	self:_update_network_position(t, dt, self._unit:position())
end

function PlayerParableFall:_update_check_actions(t, dt) end

function PlayerParableFall:_get_walk_headbob()
	return 0
end

function PlayerParableFall:_set_camera_limits()
	self._camera_unit:base():set_pitch(self._tweak_data.camera.target_pitch)
	self._camera_unit:base():set_limits(self._tweak_data.camera.limits.spin, self._tweak_data.camera.limits.pitch)
end

function PlayerParableFall:_remove_camera_limits()
	self._camera_unit:base():remove_limits()
	self._camera_unit:base():set_target_tilt(0)
end

function PlayerParableFall:_pitch_down()
	local t = Application:time()

	self._camera_unit:base():animate_pitch(t, nil, self._tweak_data.camera.target_pitch, 1.7)
end

function PlayerParableFall:tweak_data_clbk_reload() end