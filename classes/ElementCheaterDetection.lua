core:import("CoreMissionScriptElement")

ElementCheaterDetection = ElementCheaterDetection or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCheaterDetection:init(...)
	ElementCheaterDetection.super.init(self, ...)
end

function ElementCheaterDetection:on_script_activated()
	self:add_callback()
end

function ElementCheaterDetection:set_enabled(enabled)
	ElementCheaterDetection.super.set_enabled(self, enabled)

	if enabled then
		self:add_callback()
	end
end

function ElementCheaterDetection:add_callback()
	if not self._callback then
		self._callback = self._mission_script:add(callback(self, self, "update_cheater_detection"), 0.1)
	end
end

function ElementCheaterDetection:remove_callback()
	if self._callback then
		self._mission_script:remove(self._callback)

		self._callback = nil
	end
end

function ElementCheaterDetection:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementCheaterDetection.super.on_executed(self, instigator)

	if not self._values.enabled then
		self:remove_callback()
	end
end

function ElementCheaterDetection:update_cheater_detection()
	if not self._values.enabled then return end

	local cheated = false
	if FreeFlightCamera and FreeFlightCamera:enabled() then
		cheated = true

		if self._values.stop_cheating then
			FreeFlightCamera:disable()
		end
	end

	-- Add more detection?

	if cheated then
		local player = managers.player:player_unit()
		if Network:is_client() then
			managers.network:session():send_to_host("to_server_mission_element_trigger", self._id, player)
		else
			self:on_executed(player)
		end
	end
end

if BLE then
	Hooks:Add("BeardLibPostInit", "ElementCheaterDetectionEditor", function(self)
		EditorCheaterDetection = EditorCheaterDetection or class(MissionScriptEditor)

		function EditorCheaterDetection:create_element()
		    self.super.create_element(self)

		    self._element.class = "ElementCheaterDetection"
		end

		function EditorCheaterDetection:_build_panel()
			self:_create_panel()

			self:BooleanCtrl("stop_cheating")
			self:Text("Detect \"cheats\". (Tick to try and cancel out any \"cheats\".)")
		end

		table.insert(BLE._config.MissionElements, "ElementCheaterDetection")
	end)
end