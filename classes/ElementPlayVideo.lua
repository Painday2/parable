core:import("CoreMissionScriptElement")

ElementPlayVideo = ElementPlayVideo or class(CoreMissionScriptElement.MissionScriptElement)
ElementPlayVideo._current_video_element = nil -- Track which element is the current video source.

function ElementPlayVideo:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayVideo:on_executed(instigator)
	if not self._values.enabled then
		self._mission_script:debug_output("Element '" .. self._editor_name .. "' not enabled. Skip.", Color(1, 1, 0, 0))
		return
	end

	if instigator == managers.player:player_unit() then
		self:play_movie(self._values.movie)
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

function ElementPlayVideo:_setup_video_panels(movie)
	self._workspace = managers.hud:workspace("workspace")

	self._video_panel = self._workspace:panel():child("video_element_panel")

	if not self._video_panel then
		self._video_panel = self._workspace:panel():panel({
			name = "video_element_panel",
			layer = -9,
			visible = false
		})

		self._resolution_changed_callback = callback(self, self, "resolution_changed")
		managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)		
	end

	self._top_border = self._video_panel:child("top_border") or self._video_panel:rect({
		name = "top_border",
		visible = true,
		valign = "center",
		layer = 0,
		color = Color.black
	})
	self._right_border = self._video_panel:child("right_border") or self._video_panel:rect({
		name = "right_border",
		visible = true,
		valign = "center",
		layer = 0,
		color = Color.black
	})
	self._bottom_border = self._video_panel:child("bottom_border") or self._video_panel:rect({
		name = "bottom_border",
		visible = true,
		valign = "center",
		layer = 0,
		color = Color.black
	})
	self._left_border = self._video_panel:child("left_border") or self._video_panel:rect({
		name = "left_border",
		visible = true,
		valign = "center",
		layer = 0,
		color = Color.black
	})

	-- The renderer really does not like reusing this multiple times so create it fresh.
	if self._video and alive(self._video) then
		self._video_panel:remove(self._video)
	end

	self._video = self._video_panel:video({
		name = "video",
		video = movie or "movies/attract",
		visible = true,
		valign = "center",
		layer = 0
	})
end

function ElementPlayVideo:resolution_changed()
	self:recalculate_video_size()
end

function ElementPlayVideo:recalculate_video_size()
	if not self._video_panel then return end

	self._video_panel:set_size(self._workspace:width(), self._workspace:height())

	local video_width = self._video:video_width()
	local video_height = self._video:video_height()
	local video_aspect_ratio = video_width / video_height

	local width = self._video_panel:w()
	local height = self._video_panel:h()
	local aspect_ratio = width / height

	if aspect_ratio < video_aspect_ratio then
		video_width = width
		video_height = width / video_aspect_ratio
	else
		video_height = height
		video_width = height * video_aspect_ratio
	end

	self._video:set_size(video_width, video_height)
	self._video:set_center(width / 2, height / 2)

	local vertical_bar_height = (height - video_height) / 2
	local horizontal_bar_width = (width - video_width) / 2

	self._top_border:set_size(width, vertical_bar_height)
	self._top_border:set_lefttop(0, 0)

	self._right_border:set_size(horizontal_bar_width, height)
	self._right_border:set_rightbottom(width, height)

	self._bottom_border:set_size(width, vertical_bar_height)
	self._bottom_border:set_rightbottom(width, height)

	self._left_border:set_size(horizontal_bar_width, height)
	self._left_border:set_lefttop(0, 0)
end

function ElementPlayVideo:_stop_existing_video_thread()
	if self._video_thread then
		self._video_panel:stop(self._video_thread)
	end
end

function ElementPlayVideo:play_movie(movie)
	self:_setup_video_panels(movie)
	self:_stop_existing_video_thread()

	local current_video_element = ElementPlayVideo._current_video_element
	if current_video_element then
		current_video_element:stop_movie()

		ElementPlayVideo._current_video_element = nil
		if current_video_element == self then return end
	end
	ElementPlayVideo._current_video_element = self

	self:recalculate_video_size()
	self._video_panel:set_visible(true)

	self._video_thread = self._video_panel:animate(function(video_panel)
		wait(self._video:length())

		self:stop_movie()
	end)
end

function ElementPlayVideo:stop_movie()
	if not self._video_panel then return end

	self:_stop_existing_video_thread()

	self._video:pause()
	self._video_panel:set_visible(false)

	if self._video and alive(self._video) then
		self._video_panel:remove(self._video)
	end
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
		end

		table.insert(BLE._config.MissionElements, "ElementPlayVideo")
	end)
end