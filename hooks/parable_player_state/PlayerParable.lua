PlayerParable = PlayerParable or class(PlayerCivilian)

function PlayerParable:enter(state_data, enter_data)
	PlayerParable.super.enter(self, state_data, enter_data)

	self._state_data._health_effect_value = self._state_data._health_effect_value or 1

	self._unit:inventory():hide_equipped_unit()
end

function PlayerParable:exit(state_data, new_state_name)
	PlayerParable.super.exit(self, state_data, new_state_name)

	state_data._last_state_velocity = self._last_velocity_xy
end

function PlayerParable:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)
	self._stick_move = self._controller:get_input_axis("move")

	if mvector3.length(self._stick_move) < 0.1 or self:_interacting() then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._stick_move)
		local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

		mvector3.rotate_with(self._move_dir, cam_flat_rot)
	end

	self:_update_interaction_timers(t)

	self:_check_fall(t, dt)

	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_action_interact(t, input)

	if not new_action and self._state_data.ducking then
		self:_end_action_ducking(t)
	end

	self:_check_action_jump(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_run(t, input)
	self:_check_action_use_item(t, input)
end

function PlayerParable:_check_fall(t, dt)
	local fall_velocity = self._unit:mover():velocity().z
	local fall_limit = -400

	if fall_velocity < fall_limit and self._state_data.in_air and self._gnd_ray then
		managers.rumble:play("hard_land")
		self._ext_camera:play_shaker("player_fall_damage")

		self._unit:sound():play("player_hit")
		managers.environment_controller:hit_feedback_down()
		managers.hud:on_hit_direction(Vector3(0, 0, -1), HUDHitDirection.DAMAGE_TYPES.HEALTH, 0)

		self._state_data._health_effect_value = self._state_data._health_effect_value - 0.3
		managers.environment_controller:set_health_effect_value(self._state_data._health_effect_value)
	end
end