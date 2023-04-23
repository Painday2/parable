core:import("CoreMissionScriptElement")

ElementPlayVideo = ElementPlayVideo or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayVideo:init(...)
	log("EPV INITaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
	self:_init_panel()
	ElementPlayVideo.super.init(self, ...)
end
function ElementPlayVideo:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayVideo:on_executed(instigator)

	if not self._values.enabled then
		self._mission_script:debug_output("Element '" .. self._editor_name .. "' not enabled. Skip.", Color(1, 1, 0, 0))
		return
	end

	if instigator == managers.player:player_unit() then
		self:_play_movie(self._values.movie, self._values.width, self._values.height, self._values.duration)
	end

	ElementPlayVideo.super.on_executed(self, instigator)
end

function ElementPlayVideo:on_script_activated()
    self._mission_script:add_save_state_cb(self._id)
end

function ElementPlayVideo:save(data)
    data.save_me = true
    data.enabled = self._values.enabled
end

function ElementPlayVideo:load(data)
    self:set_enabled(data.enabled)
end

function ElementPlayVideo:_init_panel()
    self._full_workspace = managers.gui_data:create_fullscreen_workspace()
end


function ElementPlayVideo:_play_movie(movie, width, height, duration)
	if not self._full_workspace then
		self:init()
	end

    if self._played_video then
        return
    end

    local res = RenderSettings.resolution
	width = tonumber(width) or 1280
	height = tonumber(height) or 720
	duration = tonumber(duration) or 8
	local src_width = width
	local src_height = height
	local dest_width, dest_height = nil

	if res.x / res.y < src_width / src_height then
		dest_width = res.x
		dest_height = (src_height * dest_width) / src_width
	else
		dest_height = res.y
		dest_width = (src_width * dest_height) / src_height
    end

    local x = (res.x - dest_width) / 2
    local y = (res.y - dest_height) / 2

   	self.video_panel = self._full_workspace:panel():video({
		video = movie or "units/pd2_mod_zombies/movies/ascension",
		x = x,
		y = y,
		layer = -10
    })

    self._played_video = true

    wait(duration)
    self._played_video = false
end

if BLE then
	Hooks:Add("BeardLibPostInit", "ElementPlayVideo", function(self)
		EditorPlayVideo = EditorPlayVideo or class(MissionScriptEditor)
		function EditorPlayVideo:create_element()
			self.super.create_element(self)
			self._element.class = "ElementPlayVideo"
		end

		function EditorPlayVideo:_build_panel()
			self:_create_panel()
			self:PathCtrl("movie", "movie", nil, nil, {help = "The movie's path, if it is not showing in the list, it is not loaded properly."})
			self:NumberCtrl("width", {floats = 0, help = "The movie's width, Defaults to 1280"})
			self:NumberCtrl("height", {floats = 0, help = "The movie's height, Defaults to 720"})
			self:NumberCtrl("duration", {floats = 0, help = "The movie's height, Defaults to 8 seconds"})
		end


		table.insert(BLE._config.MissionElements, "ElementPlayVideo")
	end)
end