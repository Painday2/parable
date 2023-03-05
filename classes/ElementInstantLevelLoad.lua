core:import("CoreMissionScriptElement")

ElementInstantLevelLoad = ElementInstantLevelLoad or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstantLevelLoad:init(...)
	ElementInstantLevelLoad.super.init(self, ...)
end

function ElementInstantLevelLoad:client_on_executed(...)
	-- self:on_executed(...)
end

function ElementInstantLevelLoad:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	Global.instant_level_load = true

	managers.criminals:save_current_character_names()
	managers.job:stop_sounds()

	local level_id = self._values.level_id or Global.game_settings.level_id
	if level_id == "" then
		level_id = Global.game_settings.level_id
	end

	if not level_id then return end

	local level_td = tweak_data.levels[level_id]
	if not level_td then return end

	local level_name = level_id and tweak_data.levels[level_id].world_name
	if not level_name then return end

	if Global.boot_invite then
		Global.boot_invite.used = true
		Global.boot_invite.pending = false
	end

	local mission = Global.game_settings.mission ~= "none" and Global.game_settings.mission or nil
	local world_setting = Global.game_settings.world_setting

	managers.network:session():load_level(level_name, mission, world_setting, nil, level_id)

	self.super.on_executed(self, instigator)
end

if BLE then
	Hooks:Add("BeardLibPostInit", "ElementInstantLevelLoadEditor", function(self)
		EditorInstantLevelLoad = EditorInstantLevelLoad or class(MissionScriptEditor)

		function EditorInstantLevelLoad:create_element()
		    self.super.create_element(self)

		    self._element.class = "ElementInstantLevelLoad"
		    self._element.values.level_id = ""
		end

		function EditorInstantLevelLoad:_build_panel()
			self:_create_panel()

			self:StringCtrl("level_id")
			self:Text("Instantly load into a level without showing the loadout screen. (Leave blank to load the same level again.)")
		end

		table.insert(BLE._config.MissionElements, "ElementInstantLevelLoad")
	end)
end