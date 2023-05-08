PlayerParableSlide = PlayerParableSlide or class(PlayerParableFall)

function PlayerParableSlide:_update_foley(t, input) end

function PlayerParableSlide:_update_running_timers(t) end
function PlayerParableSlide:_update_zipline_timers(t, dt) end

function PlayerParableSlide:_check_action_jump(t, input) end
function PlayerParableSlide:_check_action_run(t, input) end
function PlayerParableSlide:_check_action_ladder(t, input) end

function PlayerParableSlide:_check_action_deploy_bipod(t, input) end

function PlayerParableSlide:_check_action_duck(t, input) end

local tmp_ground_from_vec = Vector3()
local tmp_ground_to_vec = Vector3()
local up_offset_vec = math.UP * 30
local down_offset_vec = math.UP * -40

function PlayerParableSlide:_update_ground_ray()
	local hips_pos = tmp_ground_from_vec
	local down_pos = tmp_ground_to_vec

	mvector3.set(hips_pos, self._pos)
	mvector3.add(hips_pos, up_offset_vec)
	mvector3.set(down_pos, hips_pos)
	mvector3.add(down_pos, down_offset_vec)

	self._gnd_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29)
	self._gnd_ray_chk = true
end

local mvec_pos_new = Vector3()
local mvec_achieved_velocity = Vector3()
local mvec_almost_final_velocity = Vector3()

function PlayerParableSlide:_update_movement(t, dt)
	local pos_new = nil
	local almost_final_velocity = nil

	if self._gnd_ray then
		pos_new = mvec_pos_new
		mvector3.set_zero(pos_new)

		almost_final_velocity = mvec_almost_final_velocity
		mvector3.set_zero(almost_final_velocity)

		local forward = self._gnd_ray.normal
		local angle = mvector3.angle(math.UP, forward)

		mvector3.set_z(forward, 0)
		mvector3.normalize(forward)

		local wanted_slide_speed = 30 * angle
		local acceleration = 3000
		local decceleration = 250

		mvector3.multiply(forward, wanted_slide_speed)
		mvector3.add(almost_final_velocity, forward)

		local achieved_velocity = mvec_achieved_velocity

		if mvector3.length(almost_final_velocity) < mvector3.length(self._last_velocity_xy) then
			mvector3.step(achieved_velocity, self._last_velocity_xy, almost_final_velocity, decceleration * dt)
		else
			mvector3.step(achieved_velocity, self._last_velocity_xy, almost_final_velocity, acceleration * dt)
		end

		if mvector3.is_zero(self._last_velocity_xy) then
			mvector3.set_length(achieved_velocity, math.max(achieved_velocity:length(), 100))
		end

		mvector3.add(pos_new, achieved_velocity)
	elseif not mvector3.is_zero(self._last_velocity_xy) then
		pos_new = mvec_pos_new
		mvector3.set_zero(pos_new)

		local decceleration = 250
		local achieved_velocity = math.step(self._last_velocity_xy, Vector3(), decceleration * dt)

		mvector3.set(pos_new, achieved_velocity)
	end

	local ground_z = self:_chk_floor_moving_pos()
	if ground_z then
		if not pos_new then
			pos_new = mvec_pos_new

			mvector3.set(pos_new, self._pos)
		end

		mvector3.set_z(pos_new, ground_z)
	end

	if pos_new then
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._unit:movement():set_position(pos_new)
		mvector3.set(self._last_velocity_xy, pos_new)
		mvector3.subtract(self._last_velocity_xy, self._pos)
		mvector3.divide(self._last_velocity_xy, dt)

		local camera_speed = 300

		-- local limits_table = self._camera_unit:base()._limits
		-- local spin_target = self._last_velocity_xy:normalized():to_polar().spin

		-- limits_table.spin.mid = math.step(limits_table.spin.mid, spin_target, dt * camera_speed)
		-- limits_table.pitch.mid = math.step(limits_table.pitch.mid, 0, dt * camera_speed)

		-- local camera_properties = self._camera_unit:base()._camera_properties

		-- local relative_spin = (camera_properties.spin % 360) - limits_table.spin.mid
		-- local relative_pitch = (camera_properties.pitch % 360) - limits_table.pitch.mid

		-- local spin_upper = limits_table.spin.offset
		-- local spin_lower = -limits_table.spin.offset

		-- if relative_spin > spin_upper then
		-- 	relative_spin = math.step(relative_spin, spin_upper, dt * camera_speed)
		-- elseif relative_spin < spin_lower then
		-- 	relative_spin = math.step(relative_spin, spin_lower, dt * camera_speed)
		-- else
		-- 	relative_spin = nil
		-- end

		-- local pitch_upper = limits_table.pitch.offset
		-- local pitch_lower = -limits_table.pitch.offset

		-- if relative_pitch > pitch_upper then
		-- 	relative_pitch = math.step(relative_pitch, pitch_upper, dt * camera_speed)
		-- elseif relative_pitch < pitch_lower then
		-- 	relative_pitch = math.step(relative_pitch, pitch_lower, dt * camera_speed)
		-- else
		-- 	relative_pitch = nil
		-- end

		-- if relative_spin then
		-- 	camera_properties.spin = relative_spin + limits_table.spin.mid
		-- end

		-- if relative_pitch then
		-- 	camera_properties.pitch = relative_pitch + limits_table.pitch.mid
		-- end
	else
		mvector3.set_static(self._last_velocity_xy, 0, 0, 0)
	end

	self._state_data.in_air = false

	local cur_pos = pos_new or self._pos
	self:_update_network_position(t, dt, cur_pos, pos_new)
end