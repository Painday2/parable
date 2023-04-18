SkyLib.Video = SkyLib.Video or class()
SkyLib.Video.CURRENT_PLAYLIST = {}
SkyLib.Video._played_video = false

function SkyLib.Video:init()
    log("Video init")
    self:_init_panel()
end

function SkyLib.Video:_init_panel()
    self._full_workspace = managers.gui_data:create_fullscreen_workspace()
end


function SkyLib.Video:_play_movie(movie, width, height)
	if not self._full_workspace then
		self:init()
	end

    if self._played_video then
        return
    end

    local res = RenderSettings.resolution
	width = tonumber(width) or 1280
	height = tonumber(height) or 720
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

    SkyLib:wait(8, function()
        self._played_video = false
    end)
end


Hooks:Add("GameSetupUpdate", "VideoPanelUpdate", function(t, dt)
    if not alive(SkyLib.Video.video_panel) then
        return
    end

	if SkyLib.Video.video_panel and SkyLib.Video.video_panel:current_frame() >= SkyLib.Video.video_panel:frames() then
		SkyLib.Video.video_panel:parent():remove(SkyLib.Video.video_panel)
	end
end)